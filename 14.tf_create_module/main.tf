# Provider Block
provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./vpc"
  vpc_vpc_cidr_block = var.vpc_cidr_block
}