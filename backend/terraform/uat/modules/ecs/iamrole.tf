#ecs task execution role and permissions
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.prefix}-ecsTaskExecutionRole"
  assume_role_policy = <<ROLEPOLICY
    {
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
    }
    ROLEPOLICY

}

resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name = "ecstask_policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "*"
        }
      ]
  })
}

/*resource "aws_iam_role_policy_attachment" "ecstask-execution-role-policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_role_policy.ecs_task_execution_role_policy.arn
}*/

#ecs autoscaling role and permissions
resource "aws_iam_role" "ecs_autoscaling_role" {
  name               = "${var.prefix}-ecsAutoscalingRole"
  assume_role_policy = <<ROLEPOLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "application-autoscaling.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
ROLEPOLICY
}

resource "aws_iam_role_policy" "ecs_autoscaling_role_policy" {
  name = "ecsautoscaling_policy"
  role = aws_iam_role.ecs_autoscaling_role.id

  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:DescribeServices",
                "ecs:UpdateService"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
  })
}