#!/bin/bash -xe

# Install SSH Keys
curl https://github.com/tomsteer1.keys > /home/ec2-user/.ssh/authorized_keys
curl https://github.com/osharpey.keys >> /home/ec2-user/.ssh/authorized_keys

# Install Docker
yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user

if [[ ! -f "/tmp/notes.db" ]]; then
	touch /tmp/notes.db
fi

sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
mv /usr/local/bin/docker-compose /bin/docker-compose

echo '
version: "3.3"
name: notes-app
services:
  nginx-proxy:
    container_name: nginx-proxy
    restart: always
    image: jwilder/nginx-proxy
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
  
  go:
    container_name: go-notes
    restart: unless-stopped
    image: osharpey/go-notes:latest
    volumes:
      - /tmp/notes.db:/app/notes.db
    expose:
      - 8080
    environment:
      - VIRTUAL_HOST=go.tomsteer.host
  rust:
    container_name: rust-notes
    restart: unless-stopped
    image: osharpey/rust-notes:latest
    expose:
      - 8080
    volumes:
      - /tmp/notes.db:/app/notes.db
    environment:
      - VIRTUAL_HOST=rust.tomsteer.host
' > docker-compose.yml

docker-compose up -d 
wall "Starting web servers" 1>&2
wall "Go http://go.tomsteer.host" 1>&2
wall "Rust http://rust.tomsteer.host" 1>&2

# Ensure Script Re-runs on Reboot
rm /var/lib/cloud/instance/sem/config_scripts_user
