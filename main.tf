terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}

provider "aws" {
    region = "eu-west-2"  
    access_key = var.access_key
    secret_key = var.secret_key
}

resource "aws_vpc" "project_vpc" {
    cidr_block = "172.31.0.0/16"
    tags = {
        Name = "project_vpc"
    }
}

resource "aws_subnet" "subnet_A" {
    vpc_id = "${aws_vpc.project_vpc.id}"
    cidr_block = "172.31.96.0/20"
    availability_zone = "eu-west-2a"
    tags = {
        Name = "project_subnet_a"
    }
}

resource "aws_subnet" "subnet_B" {
    vpc_id = "${aws_vpc.project_vpc.id}"
    cidr_block = "172.31.112.0/20"
    availability_zone = "eu-west-2b"
    tags = {
        Name = "project_subnet_b"
    }
}

resource "aws_subnet" "subnet_C" {
    vpc_id = "${aws_vpc.project_vpc.id}"
    cidr_block = "172.31.128.0/20"
    availability_zone = "eu-west-2c"
    tags = {
        Name = "project_subnet_c"
    }
}

resource "aws_security_group" "project_sg" {
    name = "project_sg"
    description = "Allow inbound SSH traffic"
    vpc_id = aws_vpc.project_vpc.id

    ingress {
        description = "inbound ssh from controller"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [aw.project_vpc.cidr_block]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "Allow SSH"
    }
}

resource "aws_instance" "deployment" {
    ami = "ami-0aaa5410833273cfe"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.subnet_B.id}"
    tags = {
        Name = "Deployment Instance"
    }
}

resource "aws_instance" "pipeline" {
    ami = "ami-0aaa5410833273cfe"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.subnet_A.id}"
    tags = {
        Name = "Pipeline Instance"
    }
}