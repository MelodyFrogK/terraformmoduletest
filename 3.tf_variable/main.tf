terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.25.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

variable "project_name" {
    description = "Project Name(프로젝트 이름)?"
    default = "MKF"

}

locals {
  common_tags ={
    Name = "${var.project_name}-VPC"
    service_name = "forum"
    owner        = "Community Team"
  }
}



#리소스 블록
// Create Public VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true

  tags = local.common_tags
}