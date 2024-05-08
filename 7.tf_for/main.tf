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

resource "aws_iam_group" "dev" {
  name = "dev"
}

resource "aws_iam_group" "emp" {
  name = "emp"
}

variable "users" {
  type = list(any)
}

resource "aws_iam_user" "test" {
  for_each = {
    for user in var.users : user.name => user
  }
  name = each.key
  tags = {
    level = each.value.level
    role = each.value.role
  }
}

resource "aws_iam_user_group_membership" "team" {
  for_each = {
    for user in var.users : user.name => user
  }
  user = each.key
  groups = each.value.is_dev ? [aws_iam_group.dev.name] : [aws_iam_group.emp.name]
}

### dev 사용자 그룹에 정책 할당
locals {
  dev = [for user in var.users : user if user.is_dev]
}

resource "aws_iam_user_policy_attachment" "dev_att" {
  for_each = {
    for user in local.dev : user.name => user
  }
  user = each.key
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}