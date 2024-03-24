resource "aws_ecs_service" "web_nginx" {
  ### basic
  name            = "web-nginx-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.web_nginx.arn

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  ### deployment
  desired_count = 1

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  scheduling_strategy = "REPLICA"

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  enable_execute_command = true

  ### network 
  network_configuration {
    subnets = var.subnet_private_ids
    security_groups = [
      aws_security_group.ecs_web_nginx.id
    ]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled = true
    log_configuration {
      log_driver = "awslogs"
      options = {
        "awslogs-region" : data.aws_region.current.name,
        "awslogs-group" : aws_cloudwatch_log_group.web_nginx.name,
        "awslogs-stream-prefix" : "web-ecs-service-connect"
      }
    }
  }

  ### load balancer
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "web-nginx"
    container_port   = 80
  }
  health_check_grace_period_seconds = 30

  ### tag
  propagate_tags = "SERVICE"
  tags = {
    "propagate-from" = "ecs-service"
  }
  enable_ecs_managed_tags = true

}
