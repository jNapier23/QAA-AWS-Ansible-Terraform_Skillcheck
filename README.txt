This repo contains my project which evidences my ability to use AWS in conjunction with Ansible and Terraform to host a small application.

The project consists of:

1 VPC with 3 subnets, 400+ ip addresses each
1 CICD EC2 instance with Docker and Jenkins installed within in subnet A
2 Deployment EC2 instances, one of which hosts the Express app from repo, within subnet B
Controller EC2 with Terraform and Ansible installed, able to ssh to VPC - This was created in AWS GUI manually.


INSTRUCTIONS FOR USE:
- Open your terminal, cd into the directory holding the .pem file provided, and enter the following command to access the Controller instance: ssh -i QAA-AWS-Ansible-Terraform_Skillcheck.pem ubuntu@18.130.236.98
- Clone the project repo with: git clone https://github.com/jNapier23/QAA-AWS-Ansible-Terraform_Skillcheck 
- Change into the cloned directory: cd QAA-AWS-Ansible-Terraform_Skillcheck
- Run create-infra file: sh create-infra.sh
- When prompted, enter the provided IAM credentials. They will need to be provided twice, once for the Terraform plan stage and once for the Terraform Apply stage
- When prompted, enter "yes"
- When the Ansible playbook runs, you will be asked to approve ssh connection to a new instance. The terminal will only ask for approval once, but you will need to enter "yes" 3 times, once for each instance being interacted with. 
- Entering "cat inventory.ini" will show the IP address of each instance. Connect to one of the deployment instances with: ssh -i sshKey.pem ec2-user@<ip address> (make a note of this IP address to view the result of the express app)
- Once connected, you will be able to finish the installation by typing: sh install-app.sh
- The terminal will be unusable whilst the express app is running, however you can check to see the result by visiting the following address in your preferred web browser: http://<ip address>:5000 
- Once finished, control+c to quit the express app, and use the "exit" command to return to the Controller instance
- Use "cat inventory.ini" to get the list of IP addresses again if you wish to connect to another instance
- When finished, run the exit script with: sh quit-project.sh [WARNING: Once this script completes successfully, the created instances will be destroyed and the controller instance will be shut down to preserve AWS resources]

