#!/bin/bash

cd wordpress || echo "ERROR! Wordpress folder not present! Exiting now..."
[ -f .env ] || echo "ERROR! Create .env file before starting. Exiting now..."
docker-compose build

cat <<EOF > systemd-wp.conf
[Unit]
Description=wp starter
After=docker.service
Requires=docker.service
[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/wordpress/repo/docker-wp/wordpress/
ExecStart=bash -c "docker-compose up -d"
ExecStop=bash -c "docker-compose down"

[Install]
WantedBy=multi-user.target
EOF

sudo cp systemd-wp.conf /etc/systemd/system/wordpress.service

