variable "name_prefix" {
  description = "Common name prefix for resources"
  type        = string
}

variable "repository_name" {
  description = "Logical repository name suffix"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for ECR encryption"
  type        = string
}

variable "ci_role_arn" {
  description = "CI role ARN for ECR push permissions"
  type        = string
  default     = ""
}

variable "eks_node_role_arn" {
  description = "EKS node role ARN for ECR pull permissions"
  type        = string
  default     = ""
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository created in this module"
  type        = string
  default     = ""
}

