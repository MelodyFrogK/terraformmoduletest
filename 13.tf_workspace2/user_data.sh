#!/bin/bash
echo "p@ssw0rd" | passwd --stdin root
sed -i "s/^#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
systemctl restart sshd

yum update -y
yum install -y httpd
echo "<h1><color=red>WoW! Welcome to Terraform TEST Web server 1!</font></h1>" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd