output "s3_endpoint_id" {
  value       = try(aws_vpc_endpoint.s3[0].id, null)
  description = "S3 VPC endpoint ID"
}