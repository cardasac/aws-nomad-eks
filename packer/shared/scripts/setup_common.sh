#!/bin/bash
set -e

sudo dnf install -y docker
sudo usermod -aG docker $USER
newgrp docker

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

sudo dnf install -y dmidecode
