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