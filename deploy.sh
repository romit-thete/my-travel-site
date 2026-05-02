#!/bin/bash

docker stop travel-site || true
docker rm travel-site || true
docker network prune || true

docker build -t travel-site /home/ubuntu/app/webapp/.
docker network create my-network
docker run -d \
  --name travel-site \
  --network my-network \
  --restart always \
  -e SITE_NAME="My Travel Page 🌍" \
  -e LOCATION="Berlin 🇩🇪" \
  travel-site

docker run -d -p 80:80 \
  --name nginx-proxy \
  --network my-network \
  -v /home/ubuntu/app/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx

sleep 2
curl -f http://localhost/health.html || (echo "Health check failed" && exit 1)
