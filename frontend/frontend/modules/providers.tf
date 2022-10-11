terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  /*backend "s3" {
    bucket = "notfound404.click-tfbackend"
    key = "test/terraform.tfstate"
    region = "ap-southeast-2"
  }*/
}

provider "aws" {
  region = "ap-southeast-2"
}

provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}