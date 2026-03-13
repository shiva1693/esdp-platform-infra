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