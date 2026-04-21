variable "org" {
  type = string
}

variable "platform" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "region_code" {
  type = string
}

variable "owner" {
  type = string
}

variable "cost_center" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "pod_subnet_cidrs" {
  description = "CIDR blocks for dedicated pod subnets"
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "ci_role_arn" {
  description = "GitHub Actions CI IAM role ARN"
  type        = string
  default     = ""
}

variable "eks_node_role_arn" {
  description = "EKS node IAM role ARN"
  type        = string
  default     = ""
}

variable "github_repos" {
  description = "GitHub repos allowed to assume CI role"
  type        = list(string)
}

variable "github_branch" {
  description = "GitHub branch allowed to assume CI role"
  type        = string
  default     = ""
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "app"
}

