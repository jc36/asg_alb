#!/bin/bash

apt update && apt install -y apache2
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ubuntu
chown -R ubuntu:apache /var/www
#echo "<h1>It is working</h1>" > /var/www/html/index.html