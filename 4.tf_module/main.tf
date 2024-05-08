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

variable "project_name" {
  default = "TEST"
}

locals {
  common_tags = {
    Name = "${var.project_name}"
  }
}


module "vpc" {
  source  = "tedilabs/network/aws//modules/vpc"
  version = "0.24.0"

  name       = "${var.project_name}_VPC"
  cidr_block = "10.0.0.0/16"

  dns_hostnames_enabled = true
  internet_gateway_enabled = true

  tags = local.common_tags
}

# Pub Subnet Group
module "test_pub_sn" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"

  name = "${var.project_name}_pub_sn"
  subnets = {
    "${var.project_name}_pub_1" = {
      cidr_block = "10.0.1.0/24"
      availability_zone_id = "apne2-az1"
    }
    "${var.project_name}_pub_2" = {
      cidr_block = "10.0.2.0/24"
      availability_zone_id = "apne2-az3"
    }
  }
  vpc_id = module.vpc.id
  tags = local.common_tags
}

# Pri Subnet Group
module "test_pri_sn" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"

  name = "${var.project_name}_pri_sn"
  subnets = {
    "${var.project_name}_pri_sn1" = {
      cidr_block = "10.0.3.0/24"
      availability_zone_id = "apne2-az1"
    }
    "${var.project_name}_pri_sn2" = {
      cidr_block = "10.0.4.0/24"
      availability_zone_id = "apne2-az3"
    }
  }
  vpc_id = module.vpc.id
  tags = local.common_tags
}

# Public Route Table
module "test_pub_rt" {
  source  = "tedilabs/network/aws//modules/route-table"
  version = "0.24.0"

  name = "${var.project_name}_pub_rt"
  vpc_id = module.vpc.id

  ipv4_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.vpc.internet_gateway_id
    }
  ]

  subnets = module.test_pub_sn.ids
  tags = local.common_tags
}

# Private Route Table
module "test_pri_rt" {
  source  = "tedilabs/network/aws//modules/route-table"
  version = "0.24.0"

  name = "${var.project_name}_pri_rt"
  vpc_id = module.vpc.id

  subnets = module.test_pri_sn.ids
  tags = local.common_tags
}


# output
output "vpc_name" {
  value = module.vpc.name
  description = "vpc 이름"

}

output "vpc_id" {
  value = module.vpc.id
  description = "vpc ID"

}

output "cidr_block" {
  value = module.vpc.cidr_block
  description = "IPv4 주소 범위"
}

output "pub_sn_cidr" {
  value = module.test_pub_sn.cidr_blocks
  description = "Public cidr"
}

output "pri_sn_cidr" {
  value = module.test_pri_sn.cidr_blocks
  description = "Private cidr"
}

output "sn_all_cidr" {
  value = [
    module.test_pub_sn.cidr_blocks,
    module.test_pri_sn.cidr_blocks
  ]

}