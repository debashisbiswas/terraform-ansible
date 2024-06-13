#!/usr/bin/env bash

terraform apply

INSTANCE_IP=$(terraform output -raw instance_ip)

if [ -z "$INSTANCE_IP" ]; then
  echo "Error: Failed to get instance IP from Terraform output."
  exit 1
fi

echo "Giving time for instance to be ready..."
sleep 5

ansible-playbook -i "$INSTANCE_IP," -u ec2-user --private-key ~/.ssh/id_rsa ./ansible/setup_node_server.yml \
  --ssh-extra-args="-o StrictHostKeyChecking=no"

if [ $? -eq 0 ]; then
  echo "Ansible playbook ran successfully. Instance IP: $INSTANCE_IP"
  curl $INSTANCE_IP
else
  echo "Ansible playbook failed."
  exit 1
fi
