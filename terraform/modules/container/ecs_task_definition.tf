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
