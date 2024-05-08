yum install -y httpd
systemctl start httpd
echo "<h1><font size=20 color=blue>한국 웹 서버 1번</font></h1>" >> /var/www/html/index.html