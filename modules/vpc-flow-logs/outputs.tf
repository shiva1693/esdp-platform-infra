output "flow_log_id" {
  value       = aws_flow_log.vpc_flow_logs.id
  description = "VPC Flow Log ID"
}

output "flow_log_group_name" {
  value       = aws_cloudwatch_log_group.flow_logs.name
  description = "CloudWatch Log Group Name for VPC Flow Logs"
}