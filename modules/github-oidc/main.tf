# locals {
#   # This is OIDC URL for GitHub Actions, it is used in the trust relationship of the IAM role to allow \
#   # GitHub Actions to assume the role
#   github_oidc_url = "https://token.actions.githubusercontent.com"

#   allowed_subjects = [
#     for repo in var.github_repos :
#     "${repo}:ref:refs/heads/${var.github_branch}"
#   ]

#   eks_assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# OIDC Provider
data "tls_certificate" "github" {
  url = local.github_oidc_url
}

resource "aws_iam_openid_connect_provider" "github" {
  url = local.github_oidc_url
  # GitHub's OIDC audience is always this value
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-github-oidc"
  })
}

# CI Role -> GithubActions assumes this role to push images to ECR
data "aws_iam_policy_document" "github_actions_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.allowed_subjects
    }
  }
}

resource "aws_iam_role" "ci" {
  name               = "${var.name_prefix}-ci-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
}

# CI Role Policy -> what GitHub Actions can do
data "aws_iam_policy_document" "ci_permissions" {
  # ECR authentication -> this is  account level, this cannot go in repo policy
  statement {
    sid    = "ECRAuthorization"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPush"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [var.ecr_repository_arn]
  }

  statement {
    sid    = "KMSForECR"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_role_policy" "ci_permissions" {
  name   = "${var.name_prefix}-ci-policy"
  role   = aws_iam_role.ci.id
  policy = data.aws_iam_policy_document.ci_permissions.json
}

# EKS Node Role -> EC2 nodes assumes this
# resource "aws_iam_role" "eks_node" {
#   name               = "${var.name_prefix}-eks-node-role"
#   assume_role_policy = local.eks_assume_role_policy

#   tags = merge(var.tags, {
#     Name = "${var.name_prefix}-eks-node-role"
#   })
# }

# EKS node Role Policy -> what EC2 nodes can do
# data "aws_iam_policy_document" "eks_node_permissions" {
#   statement {
#     sid    = "ECRAuth"
#     effect = "Allow"
#     actions = [
#       "ecr:GetAuthorizationToken"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     sid    = "ECRPull"
#     effect = "Allow"
#     actions = [
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:BatchGetImage",
#       "ecr:BatchCheckLayerAvailability"
#     ]
#     resources = [var.ecr_repository_arn]
#   }

#   statement {
#     sid    = "KMSforECR"
#     effect = "Allow"
#     actions = [
#       "kms:Decrypt",
#       "kms:DescribeKey"
#     ]
#     resources = [var.kms_key_arn]
#   }
# }

# resource "aws_iam_role_policy" "eks_node_permissions" {
#   name   = "${var.name_prefix}-eks-node-policy"
#   role   = aws_iam_role.eks_node.id
#   policy = data.aws_iam_policy_document.eks_node_permissions.json
# }

# # Attach AWS managed policies for EKS nodes
# resource "aws_iam_role_policy_attachment" "eks_node_managed" {
#   role       = aws_iam_role.eks_node.name
#   policy_arn = each.value
#   for_each = toset([
#     "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
#     "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
#     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   ])
# }

# resource "aws_iam_instance_profile" "eks_node" {
#   name = "${var.name_prefix}-eks-node-profile"
#   role = aws_iam_role.eks_node.name

#   tags = merge(var.tags, {
#     Name = "${var.name_prefix}-eks-node-profile"
#   })
# }