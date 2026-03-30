variable "name_prefix" {
  description = "Common name prefix for resources"
  type        = string
}

variable "description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for platform resources"
}

variable "deletion_window_in_days" {
  description = "KMS key deletion window"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}

variable "alias_name" {
  description = "Alias suffix for the KMS key"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}