#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    # Docker is not installed, so install it
    echo "Docker is not installed. Installing Docker..."
    if ! curl -fsSL https://get.docker.com | sh; then
        echo "Error: Docker installation failed."
        exit 1
    fi
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    # Docker Compose is not installed, so install it
    echo "Docker Compose is not installed. Installing Docker Compose..."
    if ! sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose; then
        echo "Error: Docker Compose installation failed."
        exit 1
    fi
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create docker-compose.yml file
cat <<EOT >> docker-compose.yml
---
version: "2.1"
services:
  unifi-controller:
    image: lscr.io/linuxserver/unifi-controller:latest
    container_name: unifi-controller
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - MEM_LIMIT=1024 #optional
      - MEM_STARTUP=1024 #optional
    volumes:
      - /path/to/data:/config
    ports:
      - 8443:8443
      - 3478:3478/udp
      - 10001:10001/udp
      - 8080:8080
      - 1900:1900/udp #optional
      - 8843:8843 #optional
      - 8880:8880 #optional
      - 6789:6789 #optional
      - 5514:5514/udp #optional
    restart: unless-stopped
EOT

# Change directory to the current directory
cd "$(dirname "$0")" || exit

# Start Docker Compose
if ! docker-compose up -d; then
    echo "Error: Docker Compose failed to start."
    exit 1
fi

# Get IP address
ip_address=$(hostname -I | awk '{print $1}')

# Output success message
echo "✅ Docker Compose started successfully."
echo "Access the service at https://$ip_address:8443"
