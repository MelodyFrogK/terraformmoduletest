# 테라폼 블록
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

# 프로바이더 블록
provider "local" {
}

# 리소스 블록
resource "local_file" "foo" {
  content  = "Hello Terraform~!!!"
  filename = "${path.module}/foo.txt"
}

# 데이터 블록
data "local_file" "test" {
  filename = "${path.module}/foo.txt"
}

# 아웃풋 블록
output "file_test" {
  value = data.local_file.test
}

# AWS 프로바이더 블록
provider "aws" {
}

# 리소스 블록
// Create a VPC
resource "aws_vpc" "test-vpc" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "TEST2"
  }
}

# 아웃풋 블록
output "test-vpc" {
  value = aws_vpc.test-vpc
}

# 데이터 블록
data "aws_vpcs" "test-vpc" {
}

# 아웃풋 블록
output "vpc_test" {
  value = data.aws_vpcs.test-vpc.ids
}