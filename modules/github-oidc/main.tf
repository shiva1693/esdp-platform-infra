locals {
  # This is OIDC URL for GitHub Actions, it is used in the trust relationship of the IAM role to allow \
  # GitHub Actions to assume the role
  github_oidc_url = "https://token.actions.githubusercontent.com"

  allowed_subjects = [
    for repo in var.github_repos :
    "${repo}:ref:refs/heads/${var.github_branch}"
  ]
}

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
    resources = ["arn:aws:ecr:*:*:repository/${var.name_prefix}-*"]
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