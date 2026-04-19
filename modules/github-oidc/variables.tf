variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository that GitHub Actions will push to"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt ECR images"
  type        = string
}

variable "github_branch" {
  description = "List of GitHub branches that are allowed to assume the CI role"
  type        = string
}

variable "github_repos" {
  description = "List of GitHub repos allowed to assume CI role (format: org/repo)"
  type        = list(string)
}
