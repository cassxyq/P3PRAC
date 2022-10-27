#autoscaling
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.prac.name}/${aws_ecs_service.test.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn = aws_iam_role.ecs_autoscaling_role.arn
}

resource "aws_appautoscaling_policy" "scale_up"{
  name = "${var.prefix}-scale-up"
  policy_type = "StepScaling"
  resource_id = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration{
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down"{
  name = "${var.prefix}-scale-down"
  policy_type = "StepScaling"
  resource_id = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration{
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}
