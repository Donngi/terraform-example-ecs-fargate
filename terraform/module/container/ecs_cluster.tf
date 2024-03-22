resource "aws_ecs_cluster" "example" {
  name = "example-cluster"

  # ECS Serviceで上書き可能
  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.example.arn
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

