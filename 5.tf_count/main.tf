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

#for_each와 map
resource "aws_iam_user" "for_each_map" {
  for_each = {
    kim  = {
     name = "kim"
     level = "L"
     dept = "admin"
    }
    lee  = {
     name = "lee"
     level = "M"
     dept = "dev"
    }
    park = {
     name = "kim"
     level = "H"
     dept = "dev"
    }
  }
  name = each.key
  tags = each.value
}

output "for_each_map_arn" {
  value = values(aws_iam_user.for_each_map).*.arn
}