#!/bin/bash
yum update -y
yum install httpd -y
echo "<h1>$(ec2-metadata -i)</h1>" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd