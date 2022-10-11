module "test" {
  source         = "./modules"
  domain_name    = var.domain_name
  subdomain_name = var.subdomain_name
  prefix         = var.prefix
  hostzone_id    = var.hostzone_id
}