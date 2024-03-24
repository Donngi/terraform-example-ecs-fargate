resource "aws_ecs_cluster" "example" {
  name = "example-cluster"

  ### ECS Service Connect
  service_connect_defaults {
    # ECS Serviceで上書きも可能
    namespace = aws_service_discovery_http_namespace.example.arn
  }

  ### Container Insights
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  ### ECS Exec
  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.ecs_exec.arn
      logging    = "DEFAULT"
    }
  }
}

