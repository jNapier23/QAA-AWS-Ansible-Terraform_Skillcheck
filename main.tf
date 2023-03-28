terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "latest"
        }
    }
}

provider "aws" {
    region = "eu-west-2"  
    access_key = "access_key"
    secret_key = "secret_key"
}

resource "aws_vpc" "project_vpc" {
    cidr_block = "172.128.0.0/16"
    tags = {
        Name = "project_vpc"
    }
}

resource "aws_subnet" "subnet_A" {
    vpc_id = "${aws_vpc.project_vpc.id}"
    cidr_block = "172.128.100.0/23"
    availability_zone = "eu-west-2a"
    tags {
        Name = "project_subnet_a"
    }
}

resource "aws_subnet" "subnet_B" {
    vpc_id = "${aws_vpc.project_vpc.id}"
    cidr_block = "172.128.300.0/23"
    availability_zone = "eu-west-2b"
    tags {
        Name = "project_subnet_b"
    }
}

resource "aws_subnet" "subnet_C" {
    vpc_id = "${aws_vpc.project_vpc.id}"
    cidr_block = "172.128.500.0/23"
    availability_zone = "eu-west-2c"
    tags {
        Name = "project_subnet_c"
    }
}

resource "aws_security_group" "project_sg" {
    # look up how to configure SG
}

resource "aws_ec2" "deployment" {
    ami = "ami-0aaa5410833273cfe"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.subnet_B.id}"
    tags {
        Name = "Deployment Instance"
    }
}
