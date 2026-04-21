output "name_prefix" {
  value       = module.naming.name_prefix
  description = "Name prefix for resources"
}

output "common_tags" {
  value       = module.tags.tags
  description = "Common tags for resources"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC Id"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private subnet IDs"
}

output "kms_key_id" {
  value = module.kms.key_id
}

output "kms_key_arn" {
  value = module.kms.key_arn
}

output "kms_alias_name" {
  value = module.kms.alias_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider created in this module"
  value       = module.github_oidc.github_oidc_provider_arn
}