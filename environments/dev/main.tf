module "naming" {
  source = "../../modules/naming"
  org = var.org
  platform = var.platform
  environment = var.environment
  region_code = var.region_code
}

module "tags" {
  source = "../../modules/tags"
  platform = var.platform
  environment = var.environment
  owner = var.owner
  cost_center = var.cost_center
}