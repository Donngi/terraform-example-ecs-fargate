resource "aws_iam_role" "ecs_task_execution_app" {
  name = "sample-ecs-task-execution-role-app"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_task_execution_app" {
  name = "${aws_iam_role.ecs_task_execution_app.name}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PullThroughCachePermission"
        Effect = "Allow"
        Action = [
          "ecr:BatchImportUpstreamImage",
          "ecr:CreateRepository",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pull_through_cache_app" {
  role       = aws_iam_role.ecs_task_execution_app.name
  policy_arn = aws_iam_policy.ecs_task_execution_app.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_app" {
  role       = aws_iam_role.ecs_task_execution_app.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
