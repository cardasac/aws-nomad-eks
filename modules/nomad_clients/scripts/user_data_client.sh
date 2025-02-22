#!/bin/bash

set -e

sudo bash /ops/shared/scripts/setup_nomad_client.sh '${retry_join}'
NOMAD_HCL_PATH="/etc/nomad.d/nomad.hcl"
CONSULCONFIGDIR=/etc/consul.d
sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" $NOMAD_HCL_PATH
sed -i "s/AGENT_TOKEN/${nomad_consul_token_secret}/g" $CONSULCONFIGDIR/consul.hcl
sudo systemctl start consul.service


TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && \
AWS_SERVER_TAG_NAME=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/Name)
sed -i "s/SERVER_NAME/$AWS_SERVER_TAG_NAME/g" $NOMAD_HCL_PATH

sudo systemctl restart nomad
