# service security group
resource "aws_security_group" "service-sg" {
  name   = "service-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 0
    to_port         = 65535
    security_groups = [var.alb_sg_id]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# create ecs service
resource "aws_ecs_service" "test" {
  name                               = "${var.prefix}-service"
  cluster                            = aws_ecs_cluster.prac.id
  task_definition                    = aws_ecs_task_definition.test.arn
  desired_count                      = var.app_count
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 30

  load_balancer {
    target_group_arn = var.alb_tg_arn
    container_name   = "${var.prefix}-pracapp" #same as the container name in container definition
    container_port   = var.app_port
  }

  network_configuration {
    security_groups  = [aws_security_group.service-sg.id]
    subnets          = var.private_subnet_id
    assign_public_ip = true
  }

  depends_on = [aws_iam_role.ecs_task_execution_role]
}
