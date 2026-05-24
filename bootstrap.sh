#!/bin/bash

## TODO: Update pipeline to be run only once when a new host is provisioned (maybe as a separate task / trigger)

set -euo pipefail  # stop on error

# Retry logic
retry() {
  local retries=5
  local wait=5
  local count=1

  until "$@"; do
    if [ $count -ge $retries ]; then
      echo "Command failed after $count attempts."
      return 1
    fi

    echo "Command failed. Retrying in $wait seconds..."
    sleep $wait

    count=$((count + 1))
  done
}

echo "Uninstalling older docker packages, if any..."
sudo apt remove -y \
  docker.io \
  docker-compose \
  docker-compose-v2 \
  docker-doc \
  podman-docker \
  containerd \
  runc || true

echo "Updating system..."
retry sudo apt update
retry sudo apt upgrade -y

echo "Setting up Docker's apt repository..."
retry sudo apt install -y ca-certificates curl
retry sudo install -m 0755 -d /etc/apt/keyrings
retry sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# shellcheck disable=SC1091
source /etc/os-release
CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"

# Add the repository to Apt sources:
cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.sources
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $CODENAME
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

retry sudo apt update

echo "Installing Docker..."
retry sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Installing CertBot..."
retry sudo apt install -y certbot

echo "Starting Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "Adding ubuntu user to the docker group..."
sudo usermod -aG docker ubuntu

echo "Creating app directory..."
mkdir -p /home/ubuntu/app

echo "Docker version:"
docker --version

echo "CertBot version:"
certbot --version

echo "Verifying docker installation success..."
sudo docker run hello-world

echo "Bootstrap complete 🚀"
