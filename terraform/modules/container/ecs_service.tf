resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.nginx.arn

  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  desired_count    = 0

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
