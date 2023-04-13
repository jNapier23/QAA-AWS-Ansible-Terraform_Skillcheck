#!/bin/bash

#Runs Terraform file to create infrastructure, elevates ssh key so it can be used, and runs Ansible file to install tools and packages

terraform plan
terraform apply
chmod 400 sshKey.pem
ansible-playbook -i inventory.ini install-deployment.yml
