resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    "Name" = "${var.title_name}_vpc"
  }
}

variable "vpc_cidr" {}
variable "title_name" {}
