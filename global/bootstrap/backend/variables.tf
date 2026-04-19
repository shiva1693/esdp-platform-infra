variable "project_name" {
  description = "Name of the project for tagging resources"
  type        = string
  default     = "esdp-platform-infra" // Enterprise Secure Delivery Platform (ESDP)
}

variable "region" {
  description = "AWS region for backend resources"
  type        = string
}

variable "tf_state_bucket" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
}

variable "account_regional_namespace_suffix" {
  description = "Account and regional namespace suffix for globally unique bucket naming"
  type        = string
}

variable "tags" {
  description = "Common tags for the backend resources"
  type        = map(string)
  default     = {}
}