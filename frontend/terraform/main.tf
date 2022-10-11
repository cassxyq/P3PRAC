
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "notfound404.click-tfbackend"
    key = "test/terraform.tfstate"
    region = "ap-southeast-2"
  }
}


provider "aws" {
  region = "ap-southeast-2"
}

module "s3bucket"{
  source = "./modules/s3bucket"
  domain_name = var.domain_name
  subdomain_name = var.subdomain_name
}

module "acm" {
  source = "./modules/acm"
  domain_name = var.domain_name
}

module "cloudfront" {
  source = "./modules/cloudfront"
  domain_name = var.domain_name
  subdomain_name = var.subdomain_name
  prefix = var.prefix
}

module "route53" {
  source = "./modules/route53"
  domain_name = var.domain_name
  subdomain_name = var.subdomain_name
}