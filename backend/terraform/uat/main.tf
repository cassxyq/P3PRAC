
module "network" {
  source              = "./modules/network"
  vpc_cidr_block      = var.vpc_cidr_block
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  prefix              = var.prefix
}

module "ecs" {
  source            = "./modules/ecs"
  prefix            = var.prefix
  image_url         = var.image_url
  app_port          = var.app_port
  app_count         = var.app_count
  vpc_id            = module.network.vpc.id
  private_subnet_id = module.network.private-subnets
  alb_tg_arn        = module.alb.alb-tg.arn # check out the outputs in modules
  alb_sg_id         = module.alb.alb-sg     #to see the difference of outputs
}

module "alb" {
  source           = "./modules/alb"
  hostzone_id      = var.hostzone_id
  domain_name      = var.domain_name
  prefix           = var.prefix
  vpc_id           = module.network.vpc.id
  public_subnet_id = module.network.public-subnets
}