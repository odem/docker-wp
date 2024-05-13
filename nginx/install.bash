#!/bin/bash

ORGUNIT=s29
CNAME=www.dummy.me
CERTOPTS="/C=DE/ST=HE/L=FFM/O=WP/OU=$ORGUNIT/CN=$CNAME"
KEYOUT=nginx/selfsigned.key
CRTOUT=nginx/selfsigned.crt
mkdir -p nginx
echo "CERT-Options: $CERTOPTS"
if [[ ! -f nginx/selfsigned.crt ]]; then
    echo "Generate key and certificate"
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$KEYOUT" \
        -out "$CRTOUT" \
        -subj "$CERTOPTS"
else
    echo "File is already present. Please remove first!"
fi

cat <<EOF > nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;
events {
	worker_connections 768;
}
http {
	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
	ssl_prefer_server_ciphers on;
	access_log /var/log/nginx/access.log;
	gzip on;
	upstream hostname.local {
		server 127.0.0.1:8080;
	}
	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}
EOF

cat <<EOF > nginx/nginx-wp.conf
server {
    listen 80 default_server;
    server_name _;
    return 301 https://www.\$host\$request_uri;
}
server {
    listen 443 ssl;
    server_name hostname.me;
    ssl_certificate /etc/nginx/ssl/selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/selfsigned.key;
    location / {
        proxy_pass http://hostname.local;
	proxy_set_header Host \$http_host;
	proxy_set_header X-Forwarded-Host \$http_host;
	proxy_set_header X-Real-IP \$remote_addr;
	proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
	proxy_set_header X-Forwarded-Proto \$scheme;
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
    }
}
EOF

sudo systemctl stop nginx
sudo rm -rf /etc/nginx/sites-enabled/default.conf
sudo rm -rf /etc/nginx/sites-available/default.conf
sudo rm -rf /etc/nginx/sites-available/wp.conf
sudo cp nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp nginx/nginx-wp.conf /etc/nginx/sites-available/wp.conf
sudo cp nginx/selfsigned.* /etc/nginx/ssl/
sudo ln -s /etc/nginx/sites-available/wp.conf /etc/nginx/sites-enabled/wp.conf
sudo systemctl restart nginx

