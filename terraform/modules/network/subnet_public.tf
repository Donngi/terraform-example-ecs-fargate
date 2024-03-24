resource "aws_subnet" "public" {
  count = 2

  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index * 2)

  tags = {
    Name = "example-ecs-fargate-public-${data.aws_availability_zones.available.names[count.index]}"
  }
}
