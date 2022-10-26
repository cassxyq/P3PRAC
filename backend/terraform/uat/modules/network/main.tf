# VPC
resource "aws_vpc" "ecsprac-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "ecsprac-vpc"
  }
}

//fetch available azs
data "aws_availability_zones" "available" {
  state = "available"
}

#create public and private subnets
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

# igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecsprac-vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

# public rtb and public subnets association
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.ecsprac-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.prefix}-public-rtb"
  }
}

resource "aws_route_table_association" "associate-public-subent" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.ecsprac-public[count.index].id
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table_association" "associate-private-subent" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.ecsprac-private[count.index].id
  route_table_id = aws_route_table.public-rtb.id
} //delete this resource if use nat gateway

# EIP and NAT gateway
/*resource "aws_eip" "eip" {
  vpc = true
  //depends_on = [aws_nat_gateway.ngw]
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.ecsprac-public[0].id
  tags = {
    Name = "${var.prefix}-ngw"
  }
  // depends_on = [aws_internet_gateway.igw]
}

# private rtb and private subnets association
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.ecsprac-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "${var.prefix}-private-rtb"
  }
}

resource "aws_route_table_association" "associate-private-subent" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.ecsprac-private[count.index].id
  route_table_id = aws_route_table.private-rtb.id
}*/