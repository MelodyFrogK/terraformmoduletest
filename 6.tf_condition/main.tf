terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# condition ? True : False
variable "igw_enabled" {
  type = bool
  description = "true or false"
}

# vpc 생성
resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
}

#igw 생성 또는 해제
resource "aws_internet_gateway" "test_igw" {
  count = var.igw_enabled ? 1 : 0
  vpc_id = aws_vpc.test_vpc.id
}