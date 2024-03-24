resource "aws_iam_role" "ecs_task_execution_web" {
  name = "sample-ecs-task-execution-role-web"

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

resource "aws_iam_policy" "ecs_task_execution_web" {
  name = "${aws_iam_role.ecs_task_execution_web.name}-policy"
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

resource "aws_iam_role_policy_attachment" "pull_through_cache_web" {
  role       = aws_iam_role.ecs_task_execution_web.name
  policy_arn = aws_iam_policy.ecs_task_execution_web.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_web" {
  role       = aws_iam_role.ecs_task_execution_web.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
