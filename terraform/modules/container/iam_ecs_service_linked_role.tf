# Service-linked role is shared by all ecs services and 
# if there is not service-linked role in your AWS account,
# AWS automatically create it.
# So there is no need to create this role manually.
# 
# resource "aws_iam_service_linked_role" "ecs" {
#   aws_service_name = "ecs.amazonaws.com"
# }