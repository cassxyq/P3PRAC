resource "aws_lb" "alb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = aws_subnet.ecsprac-public[1].id

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
  name        = "${var.prefix}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.ecsprac-vpc.id

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

/*resource "aws_lb_listener_certificate" "example" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate.cert.arn
}*/