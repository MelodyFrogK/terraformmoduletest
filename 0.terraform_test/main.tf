terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.24.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "TEST" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "aws_vpc"
  }
}
