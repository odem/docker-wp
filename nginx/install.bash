#!/bin/bash

ORGUNIT=dummy
CNAME=dummy
CERTOPTS="/C=DE/ST=HE/L=FFM/O=WP/OU=$ORGUNIT/CN=$CNAME"
KEYOUT=nginx/selfsigned.key
CRTOUT=nginx/selfsigned.crt
mkdir -p nginx
echo "CERT-Options: $CERTOPTS"
if [[ ! -f /etc/nginx/ssl/selfsigned.crt ]]; then
    echo "Generate key and certificate"
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$KEYOUT" \
        -out "$CRTOUT" \
        -subj "$CERTOPTS"
else
    echo "File is already present. Please remove first!"
fi

cat <<EOF > nginx/systemd-nginx.conf
[Unit]
Description=nginx starter
Before=getty@tty1.service
[Service]
Type=simple
ExecStart=/home/wordpress/repo/docker-wp/nginx/start.bash
ExecStop=/home/wordpress/repo/docker-wp/nginx/stop.bash
[Install]
WantedBy=getty.target  
EOF

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
    listen 443 ssl;
    server_name hostname.intranet;
    ssl_certificate /etc/nginx/ssl/selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/selfsigned.key;
    location / {
        proxy_pass http://hostname.local;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        # proxy_set_header Upgrade \$http_upgrade;
        # proxy_set_header Connection "upgrade";
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
    }
}
EOF
