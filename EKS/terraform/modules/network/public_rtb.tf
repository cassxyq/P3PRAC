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
}