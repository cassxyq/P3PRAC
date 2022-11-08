variable "vpc_cidr_block" {}
variable "public_subnet_cidr" {
  type        = list(string)
  description = "list of all public subnet cidr blocks"
}
variable "private_subnet_cidr" {}
variable "prefix" {}
variable "environment" {}
variable "domain_name" {}
variable "aws_region" {}
variable "hostzone_id" {}
variable "app_count" {}
variable "image_url" {}
variable "app_port" {}
variable instance_type {}