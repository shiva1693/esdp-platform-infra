variable "vpc_id" {
  description = "The ID of the VPC for which to create flow logs."
  type        = string
}

variable "log_retention_in_days" {
  description = "Number of days to retain the flow logs in CloudWatch Logs"
  type        = number
  default     = 30
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}