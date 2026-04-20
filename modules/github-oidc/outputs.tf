output "ci_role_name" {
  description = "Name of the IAM role for GitHub Actions CI"
  value       = aws_iam_role.ci.name
}

output "ci_role_arn" {
  description = "CI role ARN passed to ECR repository policy"
  value       = aws_iam_role.ci.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider created in this module"
  value       = aws_iam_openid_connect_provider.github.arn
}

# output "eks_node_role_arn" {
#   description = "EKS node role ARN passed to ECR repository policy and EKS module"
#   value       = aws_iam_role.eks_node.arn
# }

# output "eks_node_role_name" {
#   description = "EKS node role name used by EKS node group"
#   value       = aws_iam_role.eks_node.name
# }

# output "eks_node_instance_profile_arn" {
#   description = "EKS node instance profile ARN"
#   value       = aws_iam_instance_profile.eks_node.arn
# }


