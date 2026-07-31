#!/bin/bash

dnf update -y

dnf install nginx -y

systemctl enable nginx

systemctl start nginx

echo "<h1>AWS Multi Environment Platform</h1>" > /usr/share/nginx/html/index.html