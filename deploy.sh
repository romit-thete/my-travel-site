#!/bin/bash

docker stop travel-site || true
docker rm travel-site || true

docker build -t travel-site /home/ubuntu/app/webapp/.
docker run -d -p 80:80 \
  --name travel-site \
  --restart always \
  -e SITE_NAME="My Travel Page 🌍" \
  -e LOCATION="Berlin 🇩🇪" \
  travel-site

sleep 2
curl -f http://localhost/health.html || (echo "Health check failed" && exit 1)
