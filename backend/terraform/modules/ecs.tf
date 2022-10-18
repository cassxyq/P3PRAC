resource "aws_ecs_cluster" "prac" {
    name = "${var.prefix-cluster}"
}

resource "aws_ecs_task_definition" "test" {
    family = "${var.prefix}-td"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 256
    memory                   = 512
    container_definitions = data.template_file.app-td.rendered
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

data "template_file" "app-td" {
    template = file("templates/app.json.tpl")
    vars {
        prefix = var.prefix
        appimage_URL = var.image_url
        app_port = var.app_port
    }
}

resource "aws_ecs_service" "test" {
    name = "${var.prefix}-service"
    cluster = aws_ecs_cluster.prac.id
    task_definition = aws_ecs_task_definition.test.arn
    desired_count = var.app_count
    launch_type = "FARGATE"
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    health_check_grace_period_seconds = 60

    load_balancer {
        target_group_arn = aws_alb_target_group.app.arn
        container_name = "${var.prefix}-container-td" #same as the container name in container definition
        container_port = var.app_port
    }

    network_configuration {
        security_groups = [aws_security_group.service-sg.id]
        subnets = aws_subnet.ecsprac-private[count.index].id
        //assign_public_ip = true
    }

    depends_on [aws_iam_role.ecs_task_execution_role]
}