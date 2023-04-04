terraform {
    required_providers {
        aws = {
            source          = "hashicorp/aws"
            version         = "~> 4.0"
        }
    }
}

provider "aws" {
    region                  = "eu-west-2"  
    access_key              = var.access_key
    secret_key              = var.secret_key
}

//Start of SSH key generation to allow connection to CICD and deployment instances from controller
resource "tls_private_key" "private_key" {
    algorithm               = "RSA"
    rsa_bits                = 4096
}

resource "aws_key_pair" "ssh_key" { 
    key_name                = var.ssh_key_name
    public_key              = tls_private_key.private_key.public_key_openssh

    provisioner "local-exec" {
        command = "echo '${tls_private_key.private_key.private_key_pem}' > ./'${var.ssh_key_name}'.pem"
      
    }

    //Deletes generated sshKey file on Terraform Destroy
    provisioner "local-exec" {
        command             = "rm -f sshKey.pem"
        when                = destroy
    }
}
//End of keygen 

resource "aws_vpc" "project_vpc" {
    cidr_block              = "172.31.0.0/16"
    tags = {
        Name                = "project_vpc"
    }
}

resource "aws_subnet" "subnet_A" {
    vpc_id                  = "${aws_vpc.project_vpc.id}"
    cidr_block              = "172.31.96.0/20"
    availability_zone       = "eu-west-2a"
    map_public_ip_on_launch = "true"
    tags = {
        Name                = "project_subnet_a"
    }
}

resource "aws_subnet" "subnet_B" {
    vpc_id                  = "${aws_vpc.project_vpc.id}"
    cidr_block              = "172.31.112.0/20"
    availability_zone       = "eu-west-2b"
    map_public_ip_on_launch = "true"
    tags = {
        Name                = "project_subnet_b"
    }
}

resource "aws_subnet" "subnet_C" {
    vpc_id                  = "${aws_vpc.project_vpc.id}"
    cidr_block              = "172.31.128.0/20"
    availability_zone       = "eu-west-2c"
    map_public_ip_on_launch = "true"
    tags = {
        Name                = "project_subnet_c"
    }
}

resource "aws_internet_gateway" "project_gateway" {
    vpc_id                  = "${aws_vpc.project_vpc.id}"
    tags = {
        Name                = "Project Internet Gateway"
    }
}

resource "aws_route_table" "project_public_route" {
    vpc_id                  = "${aws_vpc.project_vpc.id}"

    route {
        cidr_block          = "0.0.0.0/0"
        gateway_id          = "${aws_internet_gateway.project_gateway.id}"
    }

    tags = {
        Name                = "Project Route Table"
    }
}

resource "aws_route_table_association" "project_public_subnet_A" {
    subnet_id               = "${aws_subnet.subnet_A.id}"
    route_table_id          = "${aws_route_table.project_public_route.id}"
}

resource "aws_route_table_association" "project_public_subnet_B" {
    subnet_id               = "${aws_subnet.subnet_B.id}"
    route_table_id          = "${aws_route_table.project_public_route.id}"
}

resource "aws_route_table_association" "project_public_subnet_C" {
    subnet_id               = "${aws_subnet.subnet_C.id}"
    route_table_id          = "${aws_route_table.project_public_route.id}"
}

resource "aws_security_group" "project_sg" {
    name                    = "project_sg"
    description             = "Allow inbound traffic"
    vpc_id                  = aws_vpc.project_vpc.id

    ingress {
        description         = "inbound ssh from vpc"
        from_port           = 22
        to_port             = 22
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]  ##This will need to get changed when controller instance switches from test instance
    }

    ingress {
        description         = "mySQL inbound from pipeline"
        from_port           = 3306
        to_port             = 3306
        protocol            = "tcp"
        cidr_blocks         = ["${aws_subnet.subnet_A.cidr_block}"] 
    }

    ingress {
        description         = "jenkins inbound from pipeline"
        from_port           = 8080
        to_port             = 8080
        protocol            = "tcp"
        cidr_blocks         = ["${aws_subnet.subnet_A.cidr_block}"] 
    }
    
    ingress {
        description         = "http inbound from anywhere to access hosted content"
        from_port           = 80
        to_port             = 80
        protocol            = "tcp"
        cidr_blocks         = "0.0.0.0/0"
    }
    
    egress {
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
        ipv6_cidr_blocks    = ["::/0"]
    }
    tags = {
        Name                = "Allow SSH, mySQL, and Jenkins"
    }
}

resource "aws_instance" "deployment1" {
    ami                     = "ami-061fbd84f343c52d5"
    instance_type           = "t2.micro"
    key_name                = var.ssh_key_name
    subnet_id               = "${aws_subnet.subnet_B.id}"
    vpc_security_group_ids  = ["${aws_security_group.project_sg.id}"]
    tags = {
        Name                = "Deployment Instance 1"
    }
}

resource "aws_instance" "deployment2" {
    ami                     = "ami-061fbd84f343c52d5"
    instance_type           = "t2.micro"
    key_name                = var.ssh_key_name
    subnet_id               = "${aws_subnet.subnet_B.id}"
    vpc_security_group_ids  = ["${aws_security_group.project_sg.id}"]
    tags = {
        Name                = "Deployment Instance 2"
    }
}

//Creates new instance for Jenkins and Docker
resource "aws_instance" "pipeline" {
    ami                     = "ami-061fbd84f343c52d5"
    instance_type           = "t2.micro"
    key_name                = var.ssh_key_name
    subnet_id               = "${aws_subnet.subnet_A.id}"
    vpc_security_group_ids  = ["${aws_security_group.project_sg.id}"]
    
    connection {
        type                = "ssh"
        user                = "ec2-user"
        host                = self.public_ip
        private_key         = tls_private_key.private_key.private_key_pem
    }

    //An attempt to create a copy of the generated SSH Key file within the Pipeline instance
    provisioner "local-exec" {
        command = "echo '${tls_private_key.private_key.private_key_pem}' > ./'${var.ssh_key_name}'.pem"
      
    }

    provisioner "remote-exec" {
    inline = [
        //installs java
        "sudo yum update -y",
        "sudo amazon-linux-extras install java-openjdk11 -y",
        //installs jenkins
        "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
        "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
        "sudo yum upgrade",
        "sudo yum install jenkins -y",
        "sudo systemctl start jenkins"
    ]

    }
    
    tags = {
        Name                = "Pipeline Instance"
    }

}


//Generates inventory file for Ansible to use
resource "local_file" "inventory" {
    filename = "inventory.ini"
    content = <<EOF
    [CICD]
    ${aws_instance.pipeline.public_ip}
    [Deployment]
    ${aws_instance.deployment1.public_ip}
    ${aws_instance.deployment2.public_ip}
    [CICD:vars]
    ansible_ssh_user=ec2-user
    ansible_ssh_private_key_file=sshKey.pem
    [Deployment:vars]
    ansible_ssh_user=ec2-user
    ansible_ssh_private_key_file=sshKey.pem
    EOF   
}
