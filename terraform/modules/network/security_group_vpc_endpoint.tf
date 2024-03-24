resource "aws_security_group" "vpc_endpoint" {
  name        = "example-ecs-fargate-vpc-endpoint"
  description = "For interface vpc endpoints"

  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}
