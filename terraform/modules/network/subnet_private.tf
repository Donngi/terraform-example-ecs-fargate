resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index * 2 + 1)

  tags = {
    Name = "example-ecs-fargate-private-${data.aws_availability_zones.available.names[count.index]}"
  }
}
