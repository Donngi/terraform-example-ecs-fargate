resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "vpce-example-ecs-fargate-s3"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id = aws_vpc.main.id

  service_name      = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private[0].id,
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-example-ecs-fargate-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id = aws_vpc.main.id

  service_name      = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private[0].id,
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-example-ecs-fargate-ecr-api"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id = aws_vpc.main.id

  service_name      = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private[0].id,
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-example-ecs-fargate-ecr-cloudwatch-logs"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id = aws_vpc.main.id

  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private[0].id,
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-example-ecs-fargate-ecr-ssmmessages"
  }
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id = aws_vpc.main.id

  service_name      = "com.amazonaws.${data.aws_region.current.name}.kms"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private[0].id,
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-example-ecs-fargate-ecr-kms"
  }
}
