variable "vpc_id" {
  type        = string
  description = "The ID of the VPC for which to create endpoints."
}

variable "route_table_ids" {
  description = "Route tables for gateway endpoints"
  type        = list(string)
}

variable "enable_s3_endpoint" {
  description = "Enable S3 gateway endpoint"
  type        = bool
  default     = true
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming the VPC endpoints."
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
}

