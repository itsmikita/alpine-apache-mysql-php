#!/bin/bash

# Set environment variables
DB_NAME="dev"
DB_USER="user"
DB_PASS="password"
ROOT_PASS="root_password"
POD_NAME="dev_pod"
CONTAINER_NAME="dev"

# Create public directory (if not exists)
[ -d public ] || mkdir public

# Create mysql data directory (if not exists)
[ -d mysql ] || mkdir mysql

# Remove previous attempts
podman pod rm -f $POD_NAME

# Build image
#podman build --no-cache -t aamp:latest .

# Create a pod
podman pod create -n $POD_NAME -p 3306:3306 -p 0.0.0.0:8090:80/tcp

# Run mariadb container
podman run --detach --pod $POD_NAME \
  -e MYSQL_ROOT_PASSWORD=$ROOT_PASS \
  -e MYSQL_DATABASE=$DB_NAME \
  -e MYSQL_PASSWORD=$DB_PASS \
  -e MYSQL_USER=$DB_USER \
  --name $CONTAINER_NAME \
  -v ./mysql:/var/lib/mysql \
  -v ./public:/var/www/localhost/htdocs \
  localhost/aamp:latest
  