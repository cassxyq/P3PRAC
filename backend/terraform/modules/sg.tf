resource "aws_security_group" "lb-sg" {
  name        = "alb_sg"
  description = "Allow inbound traffic to ALB"
  vpc_id      = aws_vpc.ecsprac-vpc.id

  ingress {
    description      = "traffic from anywhere"
    protocl          = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  /*ingress {
        description = "app port"
        from_port = var.app_port
        to_port = var.app_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }*/

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  /*tags {
        Name = "alb-sg"
    }*/
}

resource "aws_security_group" "service-sg" {
  name   = "service-sg"
  vpc_id = aws_vpc.ecsprac-vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 0
    to_port         = 65535
    security_groups = [aws_security_group.lb-sg.id]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}