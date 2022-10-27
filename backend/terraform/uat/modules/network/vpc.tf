

resource "aws_vpc" "ecsprac-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "ecsprac-vpc"
  }
}

# fetch available azs
data "aws_availability_zones" "available" {
  state = "available"
}



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