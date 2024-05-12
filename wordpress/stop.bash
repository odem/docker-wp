#!/bin/bash

#FOLDER=/home/wordpress/repo/docker-wp/wordpress
FOLDER=wordpress
[ -d "$FOLDER" ] ||  exit 1
[ -f "$FOLDER"/.env ] || exit 2
cd "$FOLDER" || exit 3

docker-compose down -f

