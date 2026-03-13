module "naming" {
  source      = "../../modules/naming"
  org         = var.org
  platform    = var.platform
  environment = var.environment
  region      = var.region
  region_code = var.region_code
}

module "tags" {
  source      = "../../modules/tags"
  platform    = var.platform
  environment = var.environment
  owner       = var.owner
  cost_center = var.cost_center
}

module "vpc" {
  source  = "../../modules/vpc"
  name_prefix  = module.naming.name_prefix
  tags   = module.tags.tags
  vpc_cidr   = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway




}