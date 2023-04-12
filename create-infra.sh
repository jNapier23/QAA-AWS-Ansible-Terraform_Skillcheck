#!/bin/bash

terraform plan
terraform apply
chmod 400 sshKey.pem
ansible-playbook -i inventory.ini install-docker.yml
