#EKS Cluster Role
data "aws_iam_policy_document" "eks_cluster_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.name_prefix}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_trust.json
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eks-cluster-role"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Node Role
data "aws_iam_policy_document" "eks_node_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${var.name_prefix}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_trust.json
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eks-node-role"
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_managed" {
  for_each = toset(
    [
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])
  role       = aws_iam_role.eks_node.name
  policy_arn = each.value
}

#Managed Policy gives Broad ECR policy but as ECR is KMS encrypted, need policy for EKS node to decrypt it
data "aws_iam_policy_document" "eks_node_custom" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_policy" "eks_node_custom" {
  name   = "${var.name_prefix}-eks-node-custom-policy"
  policy = data.aws_iam_policy_document.eks_node_custom.json
}

resource "aws_iam_role_policy_attachment" "eks_node_custom" {
  role       = aws_iam_role.eks_node.name
  policy_arn = aws_iam_policy.eks_node_custom.arn
}

resource "aws_iam_instance_profile" "eks_node" {
  name = "${var.name_prefix}-eks-node-profile"
  role = aws_iam_role.eks_node.name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eks-node-profile"
  })
}