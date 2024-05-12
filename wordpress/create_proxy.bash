#!/bin/bash

cd wordpress || echo "ERROR! Wordpress folder not present! Exiting now..."
[ -f .env ] || echo "ERROR! Create .env file before starting. Exiting now..."
docker-compose build

cat <<EOF > systemd-wp.conf
[Unit]
Description=wp starter
Before=getty@tty1.service
[Service]
Type=simple
ExecStart=/home/wordpress/repo/docker-wp/wordpress/start.bash
ExecStop=/home/wordpress/repo/docker-wp/wordpress/stop.bash
[Install]
WantedBy=getty.target
EOF



