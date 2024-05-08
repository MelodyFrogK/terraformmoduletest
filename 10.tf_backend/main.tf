# Terraform Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
  backend "s3" {
    bucket = "soldesk-terraform-mfk"
    key    = "test/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

# Provider Block
provider "aws" {
  region = "ap-northeast-2"
}

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
resource "aws_iam_user" "users" {
  for_each = {
    for x in var.users : x.name => x
  }
  name = each.key


  tags = {
    Name = each.value.name
    level = each.value.level
    role = each.value.role
  }
}

# Attch Group
resource "aws_iam_user_group_membership" "team" {
  for_each = {
    for x in var.users : x.name => x
  }
  user = each.key
  groups = each.value.is_dev ? [aws_iam_group.dev.name, aws_iam_group.emp.name] : [aws_iam_group.emp.name]
}