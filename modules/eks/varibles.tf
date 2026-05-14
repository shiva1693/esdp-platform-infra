# Naming & Tags
variable "name_prefix" {
  description = "Prefix for all resource names(like 'esdp-dev-euw2')"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster separate from name_prefix because K8s has naming rules"
  type        = string
  default     = null
  # If null, we'll derive it from name_prefix in locals
  # This gives flexibility: caller can override, or accept the default
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Cluster Configuration
variable "kubernetes_version" {
    description = "K8s version for EKS Cluster"
    type        = string
    default     = "1.32"
}

variable "enabled_log_types" {
    description = "List of control plane log types to enable and send to Cloudwatch"
    type        = list(string)
    default     = ["api", "audit", "authenticator"]
    #Skippinh controllerManager and scheduler for now as they are not critical for our use case and can generate a lot of logs which may increase costs. 
}   

variable "endpoint_private_access" {
  description = "To check whether the API server is reachable from within the VPC"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "To check whether the API server is reachable from outside the VPC"
  type        = bool
  default     = true 
  #Set to true for dev env
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint lock this down"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  # Production: set this to office IP or VPN CIDR
  # Example ["203.0.113.0/24"], only office IP range or VPN can reach the kubectl
}

# Networking Configuration
variable "vpc_id" {
    description = "VPC ID where EKS cluster will be deployed"
    type        = string
}

variable "private_subnet_ids" {
    description = "Subnet Ids for control Plane ENIs and worker nodes"
    type        = list(string)
}

variable "pod_subnet_ids_by_az" {
    description = "Map of AZ to list of subnet IDs for pod networking (for custom CNI). Example: { 'us-east-1a' = ['subnet-123', 'subnet-456'], 'us-east-1b' = ['subnet-789'] }"
    type        = map(list(string))
    default     = {}
    # If empty, we'll use the private_subnet_ids for both control plane and pods with AWS CNI
}

# Encryption Configuration
variable "kms_key_arn" {
    description = "ARN of KMS key to use for encrypting EKS secrets. If not provided, secrets will stored in plaintext"
    type        = string
    default     = null
}

#Node Group Configuration
variable "system_node_config" {
    description = "Configuration for system node group (critical addons). If null, system node group will not be created"
    type = object({
        instance_types = list(string)
        desired_size = number
        max_size = number
        min_size = number
        disk_size = number
    })
    default = {
        instance_types = ["t3.medium"]
        desired_size = 2
        max_size = 3
        min_size = 2
        disk_size = 50
    }
}

variable "app_node_config" {
    description = "Configuration for application node group."
    type = object({
        instance_types = list(string)
        desired_size = number
        max_size = number
        min_size = number
        disk_size = number
    })
    default = {
        instance_types = ["t3.medium"]
        desired_size = 2
        max_size = 5
        min_size = 1
        disk_size = 100
    }
}

#Access Control Configuration
variable "cluster_admins" {
    description = "IAM role/user ARNs that get full cluster admin access"
    type        = list(object({
        principal_arn = string 
        type = string
    }))
    default     = []
}

variable "cluster_devs" {
    description = "IAM role/user ARNs that get namespace-scoped developer access"
    type = list(object({
        principal_arn = string
        type = string
    }))
    default = []
}

variable "cluster_devs" {
    description = "IAM role/user ARNs that get namespace-scoped developer access"
    type = list(object({
        principal_arn = string
        type = string
    }))
    default = []
}

variable "ci_role_arn" {
    description = "IAM role ARN for CI/CD pipeline, gets deploy access only"
    type = string
    default = null
}

#AddOn Configuration
variable "addon_versions" {
    description = "Override versions for EKS managed addons, null means latest compatible"
    type = object({
        vpc_cni            = optional(string, null)
        coredns            = optional(string, null)
        kube_proxy         = optional(string, null)
        pod_identity_agent = optional(string, null)
    })
    default ={
        vpc_cni            = "v1.19.2-eksbuild.1"
        coredns            = "v1.11.4-eksbuild.2"
        kube_proxy         = "v1.32.0-eksbuild.2"
        pod_identity_agent = "v1.3.4-eksbuild.1"
    }
}