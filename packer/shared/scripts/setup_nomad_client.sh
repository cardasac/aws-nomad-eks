#!/bin/bash

set -e

CONFIGDIR=/ops/shared/config

CONSULCONFIGDIR=/etc/consul.d
NOMADCONFIGDIR=/etc/nomad.d
CONSULTEMPLATECONFIGDIR=/etc/consul-template.d
HOME_DIR=ec2-user

sleep 15

DOCKER_BRIDGE_IP_ADDRESS=(`sudo docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}'`)
RETRY_JOIN=$1

TOKEN=$(curl -X PUT "http://instance-data/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
IP_ADDRESS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://instance-data/latest/meta-data/local-ipv4)
AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/consul_client.hcl
sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $CONFIGDIR/consul_client.hcl
sudo cp $CONFIGDIR/consul_client.hcl $CONSULCONFIGDIR/consul.hcl

sudo systemctl enable consul.service

sed -i "s/AVAILABILITY_ZONE/$AVAILABILITY_ZONE/g" $CONFIGDIR/nomad_client.hcl
sudo cp $CONFIGDIR/nomad_client.hcl $NOMADCONFIGDIR/nomad.hcl

# Install and link CNI Plugins to support Consul Connect-Enabled jobs
export ARCH_CNI=$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-${ARCH_CNI}-v1.5.1.tgz"
sudo mkdir -p /opt/cni/bin && sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

sudo systemctl enable nomad.service --now
sleep 10
export NOMAD_ADDR=http://$IP_ADDRESS:4646

# Consul Template

sudo cp $CONFIGDIR/consul-template.hcl $CONSULTEMPLATECONFIGDIR/consul-template.hcl
sudo cp $CONFIGDIR/consul-template.service /etc/systemd/system/consul-template.service

# Add hostname to /etc/hosts
echo "127.0.0.1 $(hostname)" | sudo tee --append /etc/hosts

# Add systemd-resolved configuration for Consul DNS
# ref: https://developer.hashicorp.com/consul/tutorials/networking/dns-forwarding#systemd-resolved-setup
sed -i "s/DOCKER_BRIDGE_IP_ADDRESS/$DOCKER_BRIDGE_IP_ADDRESS/g" $CONFIGDIR/consul-systemd-resolved.conf
sudo mkdir -p /etc/systemd/resolved.conf.d/
sudo cp $CONFIGDIR/consul-systemd-resolved.conf /etc/systemd/resolved.conf.d/consul.conf
sudo iptables --table nat --append OUTPUT --destination localhost --protocol udp --match udp --dport 53 --jump REDIRECT --to-ports 8600
sudo iptables --table nat --append OUTPUT --destination localhost --protocol tcp --match tcp --dport 53 --jump REDIRECT --to-ports 8600
sudo systemctl restart systemd-resolved

# Set env vars for tool CLIs
echo "export VAULT_ADDR=http://$IP_ADDRESS:8200" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export NOMAD_ADDR=http://$IP_ADDRESS:4646" | sudo tee --append /home/$HOME_DIR/.bashrc
