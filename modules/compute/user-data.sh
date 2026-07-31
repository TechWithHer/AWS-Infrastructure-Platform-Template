#!/bin/bash
set -eux

dnf update -y
dnf install -y nginx

systemctl enable nginx
systemctl start nginx

cat <<EOF > /usr/share/nginx/html/index.html
<h1>AWS Multi-Environment Infrastructure Platform</h1>
EOF