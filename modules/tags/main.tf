locals {
  tags = {
    Project     = "enterprise-secure-delivery-platform "
    Platform    = var.platform
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
    Repository  = "esdp-platform-infra"
    CostCenter  = var.cost_center
  }
}