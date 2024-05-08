# Provider Block
provider "aws" {
  region = "ap-northeast-2"
}

# Resource Block
// Default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

// Create a Security Group
resource "aws_security_group" "tf_ec2_sg" {
  name        = "tf_ec2_sg"
  description = "Allow SSH, HTTP"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "tf_ec2_sg"
  }
}

// Add Rules to a EC2 Security Group
resource "aws_security_group_rule" "tf_ec2_sg_ingress" {
  for_each = {
    ssh  = "22"
    http = "80"
  }
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_ec2_sg.id
}

resource "aws_security_group_rule" "tf_ec2_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_ec2_sg.id
}

# Data Block
data "aws_ami" "amazon_linux2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"]
}

// Userdata for a EC2 Instance
resource "aws_instance" "ec2_userdata" {
  ami                         = data.aws_ami.amazon_linux2.image_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "seoul-key"
  subnet_id                   = "subnet-0e7187a04c0dc3639"
  vpc_security_group_ids      = [aws_security_group.tf_ec2_sg.id]
  user_data                   = <<EOT
  #!/bin/bash
  yum install -y httpd
  echo "<h1>userdata EC2</h1>" >> /var/www/html/index.html
  systemctl start httpd & systemctl enable httpd
  EOT

  tags = {
    Name = "ec2_userdata"
  }
}

# Output Block
output "ec2_userdata_info" {
  value = {
    pub_ip  = aws_instance.ec2_userdata.public_ip
    pub_dns = aws_instance.ec2_userdata.public_dns
    pri_ip  = aws_instance.ec2_userdata.private_ip
    pri_dns = aws_instance.ec2_userdata.private_dns
  }
}

// Provisioner for a EC2 Instance
resource "aws_instance" "ec2_provisioner" {
  ami                         = data.aws_ami.amazon_linux2.image_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "seoul-key"
  subnet_id                   = "subnet-0e7187a04c0dc3639"
  vpc_security_group_ids      = [aws_security_group.tf_ec2_sg.id]

  user_data = <<EOT
  #!/bin/bash
  echo "p@ssw0rd" | passwd --stdin root
  sed -i "s/^#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
  sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  systemctl restart sshd
  EOT

  provisioner "remote-exec" {
    inline = [
      "yum install -y httpd",
      "systemctl start httpd & systemctl enable httpd"
    ]
    connection {
      host     = self.public_ip
      type     = "ssh"
      user     = "root"
      password = "p@ssw0rd"
    }
  }

  tags = {
    Name = "ec2_provisioner"
  }
}

# Output Block
output "ec2_provisioner_info" {
  value = {
    pub_ip  = aws_instance.ec2_provisioner.public_ip
    pub_dns = aws_instance.ec2_provisioner.public_dns
    pri_ip  = aws_instance.ec2_provisioner.private_ip
    pri_dns = aws_instance.ec2_provisioner.private_dns
  }
}

// null resource
resource "null_resource" "ec2_provisioner" {
  triggers = {
    instance_id = aws_instance.ec2_provisioner.id
    index_html  = filesha1("${path.module}/files/index.html")
    shell_sh    = filemd5("./files/install_httpd.sh")
  }
  provisioner "file" {
    source      = "${path.module}/files/index.html"
    destination = "/var/www/html/index.html"

    connection {
      host     = aws_instance.ec2_provisioner.public_ip
      type     = "ssh"
      user     = "root"
      password = "p@ssw0rd"
    }
  }
  provisioner "remote-exec" {
    script = "./files/install_httpd.sh"

    connection {
      host     = aws_instance.ec2_provisioner.public_ip
      type     = "ssh"
      user     = "root"
      password = "p@ssw0rd"
    }
  }
}