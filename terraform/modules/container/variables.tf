variable "vpc_id" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "subnet_private_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}
