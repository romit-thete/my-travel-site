#!/bin/bash

docker stop travel-site || true
docker rm travel-site || true

docker build -t travel-site /home/ubuntu/app
docker run -d -p 80:80 --name travel-site travel-site

sleep 2
curl -f http://localhost/health.html || echo "Health check failed"