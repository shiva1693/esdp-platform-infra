variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt ECR images"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}