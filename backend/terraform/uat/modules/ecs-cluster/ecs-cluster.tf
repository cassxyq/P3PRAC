resource "aws_ecs_cluster" "prac" {
  name = "${var.prefix}-cluster"
}

resource "aws_ecs_task_definition" "test" {
  family                   = "${var.prefix}-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name  = "${var.prefix}-pracapp"
      image = var.image_url
      //cpu       = 256
      //memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ]
  }])
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

/*resource "aws_ecs_task_definition" "test" {
  family                   = "${var.prefix}-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  //cpu                      = 256
  //memory                   = 512
  //container_definitions    = data.template_file.app-td.rendered
  container_definitions = file("./app.json")
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
}*/

/*data "template_file" "app-td" {
  template = file("./app.json")
  vars = {
    prefix       = var.prefix
    appimage_URL = var.image_url
    app_port     = var.app_port
  }
}*/


