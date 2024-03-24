module "network" {
  source = "../../modules/network"

  cidr_block = "10.0.3.0/24"
}

module "loadbalancer" {
  source = "../../modules/loadbalancer"

  vpc_id            = module.network.vpc_id
  subnet_public_ids = module.network.subnet_public_ids
}

module "container" {
  source = "../../modules/container"

  vpc_id             = module.network.vpc_id
  cidr_block         = module.network.cidr_block
  subnet_private_ids = module.network.subnet_private_ids
  target_group_arn   = module.loadbalancer.target_group_arn
}

module "aws_ecr_pull_through_cache" {
  source = "../../modules/ecr_pull_through_cache"
}
