# ---------------------------------------------------------------------------
# ALB
# ---------------------------------------------------------------------------

resource "aws_lb" "ecs_fargate" {
  name               = "ecs-fargate"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [
    var.subnet_public_a_id,
    var.subnet_public_c_id
  ]

  # If you want to get access log, specify s3 bucket.
  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.bucket
  #     prefix  = "logs"
  #     enabled = true
  #   }
}

resource "aws_lb_listener" "ecs_fargate" {
  load_balancer_arn = aws_lb.ecs_fargate.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_fargate.arn
  }
}

resource "aws_lb_target_group" "ecs_fargate" {
  name        = "ecs-fargate"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.aws_vpc_ecs_fargate_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 3
  }
}

# ---------------------------------------------------------------------------
# Security group
# ---------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name   = "ecs-fargate-alb"
  vpc_id = var.aws_vpc_ecs_fargate_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
