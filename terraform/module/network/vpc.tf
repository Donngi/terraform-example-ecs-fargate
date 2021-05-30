# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------
resource "aws_vpc" "ecs_fargate" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-ecs-fargate"
  }
}

# ---------------------------------------------------------------------------
# Internet gateway
# ---------------------------------------------------------------------------

resource "aws_internet_gateway" "ecs_fargate" {
  vpc_id = aws_vpc.ecs_fargate.id

  tags = {
    Name = "example-ecs-fargate"
  }
}

# ---------------------------------------------------------------------------
# Public subnet a
# ---------------------------------------------------------------------------

# Subnet
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.ecs_fargate.id
  cidr_block        = cidrsubnet(aws_vpc.ecs_fargate.cidr_block, 8, 1)
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "example-ecs-fargate-public-a"
  }
}

# Route Table
resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.ecs_fargate.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_fargate.id
  }

  tags = {
    Name = "example-ecs-fargate-public-a"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

# NAT Gateway
resource "aws_nat_gateway" "public_a" {
  allocation_id = aws_eip.public_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "example-ecs-fargate-public-a"
  }

  depends_on = [aws_internet_gateway.ecs_fargate]
}

# Elastic IP for NAT Gateway
resource "aws_eip" "public_a" {
  vpc = true

  depends_on = [
    aws_internet_gateway.ecs_fargate
  ]
}

# ---------------------------------------------------------------------------
# Public subnet c
# ---------------------------------------------------------------------------

# Subnet
resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.ecs_fargate.id
  cidr_block        = cidrsubnet(aws_vpc.ecs_fargate.cidr_block, 8, 2)
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "example-ecs-fargate-public-c"
  }
}

# Route table
resource "aws_route_table" "public_c" {
  vpc_id = aws_vpc.ecs_fargate.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_fargate.id
  }

  tags = {
    Name = "example-ecs-fargate-public-c"
  }
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_c.id
}

# NAT gateway
resource "aws_nat_gateway" "public_c" {
  allocation_id = aws_eip.public_c.id
  subnet_id     = aws_subnet.public_c.id

  tags = {
    Name = "example-ecs-fargate-public-c"
  }

  depends_on = [aws_internet_gateway.ecs_fargate]
}

# Elastic IP for NAT Gateway
resource "aws_eip" "public_c" {
  vpc = true

  depends_on = [
    aws_internet_gateway.ecs_fargate
  ]
}

# ---------------------------------------------------------------------------
# Private subnet a
# ---------------------------------------------------------------------------

# Subnet
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.ecs_fargate.id
  cidr_block        = cidrsubnet(aws_vpc.ecs_fargate.cidr_block, 8, 3)
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "example-ecs-fargate-private-a"
  }
}

# Route table
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.ecs_fargate.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_a.id
  }

  tags = {
    Name = "example-ecs-fargate-private-a"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

# ---------------------------------------------------------------------------
# Private subnet c
# ---------------------------------------------------------------------------

# Subnet
resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.ecs_fargate.id
  cidr_block        = cidrsubnet(aws_vpc.ecs_fargate.cidr_block, 8, 4)
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "example-ecs-fargate-private-c"
  }
}

# Route table
resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.ecs_fargate.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_c.id
  }

  tags = {
    Name = "example-ecs-fargate-private-c"
  }
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_c.id
}
