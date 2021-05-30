# ---------------------------------------------------------------------------
# ECS Cluster
# ---------------------------------------------------------------------------

resource "aws_ecs_cluster" "example" {
  name = "ExampleCluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

