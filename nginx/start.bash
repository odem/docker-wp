#!/bin/bash

#FOLDER=/home/wordpress/repo/docker-wp/nginx
FOLDER=nginx
[ -d "$FOLDER" ] ||  exit 1
[ -f "$FOLDER"/.env ] || exit 2
cd "$FOLDER" || exit 3

docker-compose up -d

