# Terraform Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}

# Provider Block
provider "aws" {
  region = "ap-southeast-1"
}

# Variable Block
variable "mfk_name" {
  default = "tf_project"
}

# Resource Block
// Create a VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.mfk_name}_vpc"
  }
}

// Create a Internet Gateway
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "${var.mfk_name}_igw"
  }
}

// Create a Subnet
resource "aws_subnet" "tf_pub_sn" {
  for_each = {
    "10.0.1.0/24" = "ap-southeast-1a"
    "10.0.2.0/24" = "ap-southeast-1c"
  }
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags = {
    Name = "${var.mfk_name}_${each.key}_sn"
  }
}

resource "aws_subnet" "tf_pri_sn" {
  for_each = {
    "10.0.3.0/24" = "ap-southeast-1a"
    "10.0.4.0/24" = "ap-southeast-1c"
  }
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags = {
    Name = "${var.mfk_name}_${each.key}_sn"
  }
}