# ---------------------------------------------------------------------------
# ECS task definition
# ---------------------------------------------------------------------------

data "aws_region" "current" {}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  cpu                      = "256" # 0.25vCPU
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      "name" : "nginx",
      "image" : "nginx:latest",
      "portMappings" : [
        {
          "containerPort" : 80,
          "protocol" : "tcp"
        }
      ],
      "essential" : true,
      "stopTimeout" : 30,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : data.aws_region.current.name,
          "awslogs-group" : aws_cloudwatch_log_group.nginx.name,
          "awslogs-stream-prefix" : "example"
        }
      },
      "healthCheck" : {
        "command" : ["CMD-SHELL", "curl -f http://localhost/ || exit 1"],
        "interval" : 10,
        "timeout" : 30,
        "retries" : 3,
        "startPeriod" : 15,
      },
    }
  ])
}

# ---------------------------------------------------------------------------
# ECS task role
# ---------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task" {
  name = "SampleEcsTaskRole"

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

resource "aws_iam_policy" "ecs_task" {
  name = "SampleEcsTaskRolePolicy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowSSMAccessToUseEcsExec"
          "Effect" : "Allow",
          "Action" : [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

# ---------------------------------------------------------------------------
# ECS task execution role
# ---------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task_execution" {
  name = "SampleEcsTaskExecutionRole"

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------------------------------------------------------------------------
# CloudWatch Logs
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "nginx" {
  name = "/ecs/nginx"
}
