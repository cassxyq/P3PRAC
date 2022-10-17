variable "vpc_cidr_block" {}
variable "public_subnet_cidr" {
  type        = list(string)
  description = "list of all public subnet cidr blocks"
}
variable "private_subnet_cidr" {}