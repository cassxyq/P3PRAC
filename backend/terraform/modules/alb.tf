resource "aws_lb" "alb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [for subnet in aws_subnet.ecsprac-public : subnet.id]

  enable_deletion_protection = true

  /*access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }*/
}

resource "aws_alb_target_group" "app" {
    name = "${var.prefix}-alb-tg"
    port = 80 #var.app_port
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = aws_vpc.ecsprac-vpc.id

    health_check {
        healthy_threshold   = "3"
        interval            = "30"
        protocol            = "HTTP"
        matcher             = "200"
        timeout             = "3"
        unhealthy_threshold = "2"
        //path                = var.health_check_path
  }
}

resource "aws_alb_listener" "front_end" {
    load_balancer_arn = aws_alb.alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        target_group_arn = aws_alb_target_group.app.arn
        type = "forward"
    }
}