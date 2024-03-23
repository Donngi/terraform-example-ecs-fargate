resource "aws_service_discovery_http_namespace" "example" {
  name        = "example.local"
  description = "For ecs service discovery."
}
