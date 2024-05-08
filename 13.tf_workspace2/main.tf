# Terraform Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}

# Provider Block
provider "aws" {
  region = "${var.region}"
}

# Variable Block
variable "pjt_name" {
  type =  string
}

# Variable Block
variable "region" {
  type = string
}

# Variable Block
variable "az_a" {
}

# Variable Block
variable "az_b" {
}

# Variable Block
variable "cidr_block" {
  type = string
}

# Variable Block
variable "subnets_block" {
}

# Variable Block
variable "ami_block" {
  type = string
}

# Resource Block
// Create a VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.pjt_name}_vpc"
  }
}

// Create a Internet Gateway
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "${var.pjt_name}_igw"
  }
}

// Create a Subnet
resource "aws_subnet" "tf_sn" {
  for_each = {
    "${var.subnets_block}.1.0/24" = "${var.az_a}"
    "${var.subnets_block}.2.0/24" = "${var.az_b}"
    "${var.subnets_block}.3.0/24" = "${var.az_a}"
    "${var.subnets_block}.4.0/24" = "${var.az_b}"
  }
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags = {
    Name = "${var.pjt_name}_${each.key}_sn"
  }
}

// Create a Public Route Table
resource "aws_route_table" "tf_pub_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "${var.pjt_name}_pub_rt"
  }
}

// Create a Private Route Table
resource "aws_route_table" "tf_pri_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.pjt_name}_pri_rt"
  }
}

// Associate a Public Route Table With a Public Subnet
resource "aws_route_table_association" "tf_pub_rt_ass" {
  for_each = {
    pub_sn1_id = aws_subnet.tf_sn["${var.subnets_block}.1.0/24"].id
    pub_sn2_id = aws_subnet.tf_sn["${var.subnets_block}.2.0/24"].id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.tf_pub_rt.id
}

// Associate a Private Route Table With a Private Subnet
resource "aws_route_table_association" "tf_pri_rt_ass" {
  for_each = {
    pub_sn3_id = aws_subnet.tf_sn["${var.subnets_block}.3.0/24"].id
    pub_sn4_id = aws_subnet.tf_sn["${var.subnets_block}.4.0/24"].id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.tf_pri_rt.id
}

#NAT 게이트웨이 생성
resource "aws_eip" "nat_ip" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [ aws_internet_gateway.tf_igw ]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.tf_sn["${var.subnets_block}.1.0/24"].id

  tags = {
    Name = "${var.pjt_name}_nat"
  }
}


# SG 생성(tcp 80, tcp 22, icmp -1 허용)
resource "aws_security_group" "sg" {
  name        = "mfk-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    description      = "https from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }



  tags = {
    Name = "allow_tls"
  }
}

# Pub instance 2개 생성
resource "aws_instance" "pub_ec2_1" {
  ami           = "${var.ami_block}"
  instance_type = "t2.micro"

  subnet_id   = aws_subnet.tf_sn["${var.subnets_block}.1.0/24"].id
  private_ip = "${var.subnets_block}.1.100"

  associate_public_ip_address = true

  key_name               = "${var.pjt_name}-key"
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
  Name = "${var.pjt_name}_pub_ec2_1"
  }

}


# Pri instance 1개 생성
resource "aws_instance" "pri_ec2_3" {
  ami           = "${var.ami_block}"
  instance_type = "t2.micro"

  subnet_id   = aws_subnet.tf_sn["${var.subnets_block}.3.0/24"].id
  private_ip = "${var.subnets_block}.3.100"

  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
  Name = "${var.pjt_name}_pri_ec2_3"
  }

  user_data = filebase64("${path.module}/user_data.sh")
}

