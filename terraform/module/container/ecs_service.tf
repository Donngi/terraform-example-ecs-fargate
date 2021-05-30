# ---------------------------------------------------------------------------
# ECS Service
# ---------------------------------------------------------------------------

resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.nginx.arn

  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  desired_count    = 2

  enable_execute_command = true

  network_configuration {
    subnets = [
      var.subnet_private_a_id,
      var.subnet_private_c_id
    ]
    security_groups = [
      aws_security_group.ecs_nginx.id
    ]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }
  health_check_grace_period_seconds = 30

  propagate_tags = "SERVICE"
  tags = {
    "propagate-from" = "ecs-service"
  }
}

# ---------------------------------------------------------------------------
# ECS Service-linked role
# ---------------------------------------------------------------------------

# Service-linked role is shared by all ecs services and 
# if there is not service-linked role in your AWS account,
# AWS automatically create it.
# So there is no need to create this role manually.
# 
# resource "aws_iam_service_linked_role" "ecs" {
#   aws_service_name = "ecs.amazonaws.com"
# }

# ---------------------------------------------------------------------------
# Security group attached to ECS Service
# ---------------------------------------------------------------------------

resource "aws_security_group" "ecs_nginx" {
  name   = "ecs-nginx"
  vpc_id = var.aws_vpc_ecs_fargate_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.aws_vpc_ecs_fargate_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
