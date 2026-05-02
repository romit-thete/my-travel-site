#!/bin/bash

set -e  # stop on error

echo "Updating system..."
sudo apt update

echo "Installing Docker..."
sudo apt install docker.io -y

echo "Installing CertBot..."
sudo apt install certbot -y

echo "Starting Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "Adding ubuntu user to the docker group..."
sudo usermod -aG docker ubuntu
newgrp docker

echo "Creating app directory..."
mkdir -p /home/ubuntu/app

echo "Docker version:"
docker --version

echo "Bootstrap complete 🚀"
