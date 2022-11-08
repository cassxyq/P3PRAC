output "vpc" {
    value = aws_vpc.ecsprac-vpc
}

output "public-subnets" {
    value = aws_subnet.ecsprac-public.*.id
}

output "private-subnets" {
    //value = aws_subnet.ecsprac-private
    value = aws_subnet.ecsprac-private.*.id
}