#!/bin/bash

set -e

echo "Stopping old containers if any..."
docker stop travel-site || true
docker rm travel-site || true

docker stop nginx-proxy || true
docker rm nginx-proxy || true

echo "Cleaning network..."
docker network rm my-network || true

echo "Building image..."
docker build -t travel-site /home/ubuntu/app/webapp/.

echo "Creating network..."
docker network create my-network

echo "Creating certificates..."
sudo certbot certonly \
  --standalone \
  --non-interactive \
  --agree-tos \
  --email test@mail.com \
  --redirect \
  --keep-until-expiring \
  -d "$1".nip.io

echo "Starting app container..."
docker run -d \
  --name travel-site \
  --network my-network \
  --restart always \
  -e SITE_NAME="My Travel Page 🌍" \
  -e LOCATION="Berlin 🇩🇪" \
  travel-site

echo "Starting nginx proxy..."
docker run -d -p 80:80 -p 443:443 \
  --name nginx-proxy \
  --network my-network \
  -e DOMAIN="$1" \
  -v /home/ubuntu/app/nginx.template.conf:/etc/nginx/nginx.template.conf:ro \
  -v /etc/letsencrypt:/etc/letsencrypt:ro \
  nginx \
  /bin/sh -c "envsubst < /etc/nginx/nginx.template.conf > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"

echo "Waiting for startup..."
sleep 2

echo "Running health check..."
curl -f https://$1.nip.io/health.html || (echo "Health check failed" && exit 1)
docker exec travel-site curl -f https://$1.nip.io/health.html || (echo "Health check failed" && exit 1)

echo "Deployment successful 🚀"
