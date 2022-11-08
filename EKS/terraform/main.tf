module "network" {
  source              = "./modules/network"
  vpc_cidr_block      = var.vpc_cidr_block
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  prefix              = var.prefix
}

module "eks" {
    source = "./modules/eks"
}