output "vpc_id" {
  value = aws_vpc.main.id
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "subnet_private_ids" {
  value = aws_subnet.private[*].id
}

output "subnet_public_ids" {
  value = aws_subnet.public[*].id
}


