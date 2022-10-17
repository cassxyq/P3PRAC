

resource "aws_vpc" "ecsprac-vpc" {
  cidr_block = var.vpc_cidr_block
}

# fetch available azs
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
    count = length(var.public_subnet_cidr)
    subnet_id = aws_subnet.ecsprac-public[count.index].id 
    route_table_id = aws_route_table.public-rtn.id
}