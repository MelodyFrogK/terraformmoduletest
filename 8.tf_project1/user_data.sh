#!/bin/bash
echo "p@ssw0rd" | passwd --stdin root
sed -i "s/^#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
systemctl restart sshd

yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1><font size=20 color=blue>한국 웹 서버 1번</font></h1>" > /var/www/html/index.html
