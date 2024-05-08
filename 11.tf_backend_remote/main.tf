# Terraform Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "Sol_Cloud5"

    workspaces {
      name = "backend-test"
    }
  }
}

# Provider Block
provider "aws" {
  region = "ap-northeast-2"
}

# Create a User Group
resource "aws_iam_group" "dev" {
  name = "dev"
}

resource "aws_iam_group" "emp" {
  name = "emp"
}

# Variable
variable "users" {
  type = list(any)
}

# Create a User
resource "aws_iam_user" "test" {
  for_each = {
    for x in var.users : x.name => x
  }
  name = each.key

  tags = {
    Name = each.value.name
    Level = each.value.level
    Role = each.value.role
  }
}