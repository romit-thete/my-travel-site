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

echo "Starting app container..."
docker run -d \
  --name travel-site \
  --network my-network \
  --restart always \
  -e SITE_NAME="My Travel Page 🌍" \
  -e LOCATION="Berlin 🇩🇪" \
  travel-site

echo "Starting nginx proxy..."
docker run -d -p 80:80 \
  --name nginx-proxy \
  --network my-network \
  -v /home/ubuntu/app/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx

echo "Waiting for startup..."
sleep 2

echo "Running health check..."
curl -f http://localhost/health.html || (echo "Health check failed" && exit 1)
docker exec travel-site curl -f http://localhost/health.html || (echo "Health check failed" && exit 1)

echo "Deployment successful 🚀"
