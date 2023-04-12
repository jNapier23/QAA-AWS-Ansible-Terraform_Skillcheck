#!/bin/bash

terraform plan
terraform apply
ansible-playbook -i inventory.ini install-docker.yml
