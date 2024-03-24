resource "aws_route_table" "private" {
  count = length(aws_subnet.private)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = aws_subnet.private[count.index].tags["Name"]
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# aws_route_table に直接data resourceで参照した prefix list のルートを記載すると
# InvalidParameterValue: Cannot create or replace a prefix list route targeting a VPC Endpoint.
# が発生した
# Gateway Endpointへのrouteは、aws_vpc_endpoint_route_table_association で行わなくてはならない模様
# https://github.com/hashicorp/terraform-provider-aws/issues/18607
resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = length(aws_subnet.private)

  route_table_id  = aws_route_table.private[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
