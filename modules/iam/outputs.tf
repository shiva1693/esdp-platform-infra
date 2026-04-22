output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster role used when creating the cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  description = "ARN of the EKS node role used by node groups and ECR pull policy"
  value       = aws_iam_role.eks_node.arn
}

output "eks_node_instance_profile_name" {
  description = "Name of the node instance profile used in launch templates"
  value       = aws_iam_instance_profile.eks_node.name
}