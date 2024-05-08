# 테라폼 블록
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.25.0"
    }
  }
}

# 프로바이더 블록
provider "aws" {
  region = "ap-northeast-2"
}

# 데이터 블록
data "aws_ami" "amazon_linux2" {
  most_recent      = true


  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners           = ["137112412989"]
}

#리소스 블록
// Create Public VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true

  tags = {
    Name = "tf_vpc"
  }
}

// Create Public SN
resource "aws_subnet" "tf_pub_sn" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.0.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "tf_pub_sn"
  }
}

// Create InternetGateway
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_igw"
  }
}


// Create RT
resource "aws_route_table" "tf_pub_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "tf_pub_rt"
  }
}

// Associate RT to SN
resource "aws_route_table_association" "tf_pub_rt_ass" {
  subnet_id      = aws_subnet.tf_pub_sn.id
  route_table_id = aws_route_table.tf_pub_rt.id
}

// Create securitygroup
resource "aws_security_group" tf_pub_sg {
  name        = "tf_pub_sg"
  description = "allow SSH, HTTP, ICMP"
  vpc_id      = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_pub_sg"
  }
}

// Create SG rule
resource "aws_security_group_rule" "tf_pub_sg_ssh_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_pub_sg.id
}

resource "aws_security_group_rule" "tf_pub_sg_ssh_e" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_pub_sg.id
}

resource "aws_security_group_rule" "tf_pub_sg_http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_pub_sg.id
}

resource "aws_security_group_rule" "tf_pub_sg_http_e" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_pub_sg.id
}

resource "aws_security_group_rule" "tf_pub_sg_icmp_in" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_pub_sg.id
}

resource "aws_security_group_rule" "tf_pub_sg_icmp_e" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_pub_sg.id
}

// Create EC2 Instance
resource "aws_instance" "tf_web" {
  ami           = data.aws_ami.amazon_linux2.image_id
  instance_type = "t2.micro"

  associate_public_ip_address =  true

  key_name = "tf-key"
  subnet_id = aws_subnet.tf_pub_sn.id
  vpc_security_group_ids = [aws_security_group.tf_pub_sg.id]

  user_data = <<-EOT
  #!/bin/bash
  yum install -y httpd
  echo "<h1>Terraform 테스트 웹서버</h1>" > /var/www/html/index.html
  systemctl start httpd
  EOT

  tags = {
    Name = "TEST-WEB"
  }
}
