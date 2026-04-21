output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC Id"
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value       = aws_subnet.public_subnet[*].id
  description = "Public Subnet Ids"
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnet[*].id
  description = "Private Subnet Ids, this is for Node IPs only for EKS nodes"
}

# Mapping AZ → pod subnet ID
# Used by EKS module for ENIConfig — must know which subnet per AZ
output "pod_subnet_ids_by_az" {
  description = "Map of availability zone to pod subnet ID used for VPC CNI ENIConfig"
  value       = { for az, subnet in aws_subnet.pod_subnet : az => subnet.id }
}

output "pod_subnet_ids" {
  description = "List of pod subnet IDs"
  value       = values(aws_subnet.pod_subnet)[*].id
}

output "nat_gateway_ids" {
  value       = aws_nat_gateway.this[*].id
  description = "NAT Gateway Ids"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.this.id
  description = "Internet Gateway Id"
}

output "public_route_table_id" {
  value       = aws_route_table.public_rt.id
  description = "Public Route Table Id"
}

output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "Private Route Table Ids"
}


