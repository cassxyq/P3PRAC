

resource "aws_vpc" "ecsprac-vpc" {
  cidr_block = var.vpc_cidr_block
}

data "aws_availability_zones" "available" {
  state = "available"
}

/*resource "aws_subnet" "ecsprac-public1" {
    for_each = toset(var.public_subnet_cidr)
    count = 2
    vpc_id = aws_vpc.ecsprac-vpc.id
    cidr_block = each.key
    availability_zone = data.aws_availability_zones.available.names[count.index]
}*/

resource "aws_subnet" "ecsprac-public" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.ecsprac-vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "ecsprac-public${count.index + 1}"
  }
}

resource "aws_subnet" "ecsprac-private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.ecsprac-vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "ecsprac-private${count.index + 1}"
  }
}