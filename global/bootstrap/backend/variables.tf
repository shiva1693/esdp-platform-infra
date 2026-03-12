variable "project_name" {
  description = "Name of the project for tagging resources"
  type        = string
  default     = "esdp-platform-infra" // Enterprise Secure Delivery Platform (ESDP)
}

variable "tags" {
    description = "A map of tags to add to all resources"
    type        = map(string)
    default     = {}    
}

locals{
    common_tags =merge(
        {
            Project = var.project_name
            ManagedBy = "Terraform"
            Environment = "dev"
        },
        var.tags
    )
}