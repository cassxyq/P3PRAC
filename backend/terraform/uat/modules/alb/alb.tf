resource "aws_lb" "alb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = var.public_subnet_id
  enable_deletion_protection = false


  /*access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }*/
}

resource "aws_security_group" "lb-sg" {
  name        = "alb_sg"
  description = "Allow inbound traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description      = "traffic from anywhere"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "traffic from https"
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
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

resource "aws_lb_target_group" "app" {
  name        = "${var.prefix}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
    path                = "/health"
  }
}

/*resource "aws_alb_listener" "http" {
    load_balancer_arn = aws_alb.alb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        target_group_arn = aws_alb_target_group.app.arn
        type = "forward"
    }
}*/

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

/*resource "aws_lb_listener_certificate" "example" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate.cert.arn
}*/