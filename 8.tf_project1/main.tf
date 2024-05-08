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
  default = "MKF"
}

locals {
  common_tags = {
    Name = "${var.project_name}"
  }
}

# VPC 생성(192.168.0.0/16)
resource "aws_vpc" "vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${var.project_name}_vpc"
  }
}
# IGW 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}_igw"
  }
}
# Pub Subnet 2개 생성(192.168.1.0/24, 192.168.2.0/24)
resource "aws_subnet" "pub_sn1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.project_name}_pub_sn1"
  }
}

resource "aws_subnet" "pub_sn2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.project_name}_pub_sn2"
  }
}

# Pri Subnet 2개 생성(192.168.3.0/24, 192.168.4.0/24)
resource "aws_subnet" "pri_sn3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.3.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.project_name}_pri_sn3"
  }
}

resource "aws_subnet" "pri_sn4" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.4.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.project_name}_pri_sn4"
  }
}


# Routing table Pub/Pri 각 1개씩 생성
// 퍼블릭 경로 0.0.0.0/0 / private 경로 Nat gateway
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}_pub_rt"
  }
}
// 퍼블릭 서브넷 연결
resource "aws_route_table_association" "pub_sn_rt_ass1" {
  subnet_id      = aws_subnet.pub_sn1.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub_sn_rt_ass2" {
  subnet_id      = aws_subnet.pub_sn2.id
  route_table_id = aws_route_table.pub_rt.id
}

//프라이빗 라우팅 테이블
resource "aws_route_table" "pri_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.project_name}_pri_rt"
  }
}

// 프라이빗 서브넷 연결
resource "aws_route_table_association" "pri_sn_rt_ass3" {
  subnet_id      = aws_subnet.pri_sn3.id
  route_table_id = aws_route_table.pri_rt.id
}

resource "aws_route_table_association" "pri_sn_rt_ass4" {
  subnet_id      = aws_subnet.pri_sn4.id
  route_table_id = aws_route_table.pri_rt.id
}

#NAT 게이트웨이 생성
resource "aws_eip" "nat_ip" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.pub_sn1.id

  tags = {
    Name = "${var.project_name}_nat"
  }
}


# SG 생성(tcp 80, tcp 22, icmp -1 허용)
resource "aws_security_group" "sg" {
  name        = "mfk-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

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
#resource "aws_instance" "pub_ec2_1" {
#  ami           = "ami-09e70258ddbdf3c90" # ap-northeast-2
#  instance_type = "t2.micro"
#
#  subnet_id   = aws_subnet.pub_sn1.id
#  private_ip = "192.168.1.100"
#
#  associate_public_ip_address = true
#
#  key_name               = "mfk-key"
#  vpc_security_group_ids = [aws_security_group.sg.id]
#
#  tags = {
#  Name = "${var.project_name}_pub_ec2_1"
#  }
#
#}
#
#resource "aws_instance" "pub_ec2_2" {
#  ami           = "ami-09e70258ddbdf3c90" # ap-northeast-2
#  instance_type = "t2.micro"
#
#  subnet_id   = aws_subnet.pub_sn2.id
#  private_ip = "192.168.2.100"
#
#  associate_public_ip_address = true
#
#  key_name               = "mfk-key"
#  vpc_security_group_ids = [aws_security_group.sg.id]
#
#  tags = {
#  Name = "${var.project_name}_pub_ec2_2"
#  }
#
#}
#
# Pri instance 1개 생성: auto scaling groups
#resource "aws_instance" "pri_ec2_3" {
#  ami           = "ami-09e70258ddbdf3c90" # ap-northeast-2
#  instance_type = "t2.micro"
#
#  subnet_id   = aws_subnet.pri_sn3.id
#  private_ip = "192.168.3.100"
#
#  vpc_security_group_ids = [aws_security_group.sg.id]
#
#  tags = {
#  Name = "${var.project_name}_pri_ec2_3"
#  }
#
#  user_data = <<-EOT
#   #!/bin/bash
#   echo "p@ssw0rd" | passwd --stdin root
#   sed -i "s/^#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
#   sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
#   systemctl restart sshd
#
#   yum update -y
#   yum install -y httpd
#   echo "<h1><color=red>WoW! Welcome to Terraform TEST Web server 1!</font></h1>" > /var/www/html/index.html
#   systemctl start httpd
#   systemctl enable httpd
#   EOT
#}
#
## Pri instance 1개 생성: auto scaling groups
#resource "aws_instance" "pri_ec2_4" {
#  ami           = "ami-09e70258ddbdf3c90" # ap-northeast-2
#  instance_type = "t2.micro"
#
#  subnet_id   = aws_subnet.pri_sn4.id
#  private_ip = "192.168.4.100"
#
#  vpc_security_group_ids = [aws_security_group.sg.id]
#
#  tags = {
#  Name = "${var.project_name}_pri_ec2_4"
#  }
#
#  user_data = <<-EOT
#   #!/bin/bash
#   echo "p@ssw0rd" | passwd --stdin root
#   sed -i "s/^#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
#   sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
#   systemctl restart sshd
#
#   yum update -y
#   yum install -y httpd
#   echo "<h1><color=red>WoW! Welcome to Terraform TEST Web server 1!</font></h1>" > /var/www/html/index.html
#   systemctl start httpd
#   systemctl enable httpd
#   EOT
#}
#
# Alb 생성
resource "aws_lb" "alb" {
  name               = "mfk-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.pub_sn1.id, aws_subnet.pub_sn2.id]
  security_groups = [aws_security_group.sg.id]

  tags = {
  Name = "${var.project_name}_alb"
  }
}

resource "aws_lb_listener" "myhttp" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found - T101 Study"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "mfk-alb-tg" {
  name = "mfk-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 타겟그룹 attach
#resource "aws_lb_target_group_attachment" "mfk-alb-tg-att1" {
#  target_group_arn = aws_lb_target_group.mfk-alb-tg.arn
#  target_id        = aws_instance.pri_ec2_3.id
#  port             = 80
#}
#
#resource "aws_lb_target_group_attachment" "mfk-alb-tg-att2" {
#  target_group_arn = aws_lb_target_group.mfk-alb-tg.arn
#  target_id        = aws_instance.pri_ec2_4.id
#  port             = 80
#}

resource "aws_lb_listener_rule" "mfk-albrule" {
  listener_arn = aws_lb_listener.myhttp.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mfk-alb-tg.arn
  }
}

output "mkf_dns" {
  value       = aws_lb.alb.dns_name
  description = "The DNS Address of the ALB"
}

# 시작 템플릿 생성
resource "aws_launch_template" "mfk_temp" {
  name = "mfk_temp"

// 인스턴스 유형
  image_id = "ami-09e70258ddbdf3c90"

  instance_type = "t2.micro"

  key_name = "mfk-key"

  vpc_security_group_ids = [aws_security_group.sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "mfk_temp"
    }
  }

  user_data = filebase64("${path.module}/user_data.sh")
}

#오토스케일링(마켓 이미지 가져와서 사용)
resource "aws_autoscaling_group" "mfk_asg" {
  vpc_zone_identifier       = [aws_subnet.pri_sn3.id, aws_subnet.pri_sn4.id]
  max_size           = 4
  min_size           = 2

  launch_template {
    id      = aws_launch_template.mfk_temp.id
    version = "$Latest"
  }

 # ELB 연결
  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.mfk-alb-tg.arn]

}