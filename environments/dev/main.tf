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

module "kms" {
  source = "../../modules/kms"

  name_prefix = module.naming.name_prefix
  alias_name  = "platform"
  description = "KMS key for Enterprise Secure Delivery Platform resources"
  tags        = module.tags.tags
}

module "vpc" {
  source               = "../../modules/vpc"
  name_prefix          = module.naming.name_prefix
  tags                 = module.tags.tags
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
}

module "vpc_flow_logs" {
  source      = "../../modules/vpc-flow-logs"
  name_prefix = module.naming.name_prefix
  tags        = module.tags.tags
  vpc_id      = module.vpc.vpc_id
}

module "vpc_endpoints" {
  source      = "../../modules/vpc-endpoints"
  name_prefix = module.naming.name_prefix
  tags        = module.tags.tags
  vpc_id      = module.vpc.vpc_id
  route_table_ids = concat(
    [module.vpc.public_route_table_id],
    module.vpc.private_route_table_ids
  )
}

module "iam" {
  source      = "../../modules/iam"
  name_prefix = module.naming.name_prefix
  tags        = module.tags.tags
  kms_key_arn = module.kms.key_arn
}

module "github_oidc" {
  source        = "../../modules/github-oidc"
  name_prefix   = module.naming.name_prefix
  tags          = module.tags.tags
  kms_key_arn   = module.kms.key_arn
  github_repos  = var.github_repos
  github_branch = var.github_branch
}

module "ecr" {
  source              = "../../modules/ecr"
  repository_name     = var.ecr_repository_name
  ecr_repository_name = var.ecr_repository_name
  name_prefix         = module.naming.name_prefix
  tags                = module.tags.tags
  kms_key_arn         = module.kms.key_arn
  ci_role_arn         = module.github_oidc.ci_role_arn
  eks_node_role_arn   = module.iam.eks_node_role_arn
}