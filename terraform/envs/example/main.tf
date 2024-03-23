module "network" {
  source = "../../modules/network"
}

module "loadbalancer" {
  source                 = "../../modules/loadbalancer"
  subnet_public_a_id     = module.network.subnet_public_a_id
  subnet_public_c_id     = module.network.subnet_public_c_id
  aws_vpc_ecs_fargate_id = module.network.aws_vpc_ecs_fargate_id
}

module "container" {
  source                         = "../../modules/container"
  subnet_private_a_id            = module.network.subnet_private_a_id
  subnet_private_c_id            = module.network.subnet_private_c_id
  aws_vpc_ecs_fargate_id         = module.network.aws_vpc_ecs_fargate_id
  aws_vpc_ecs_fargate_cidr_block = module.network.aws_vpc_ecs_fargate_cidr_block
  target_group_arn               = module.loadbalancer.target_group_arn
}
