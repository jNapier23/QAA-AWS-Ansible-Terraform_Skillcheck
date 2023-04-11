variable "ami_id" {
    default = "ami-061fbd84f343c52d5"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "ssh_key_name" {
    default = "sshKey"
}

variable "subnet_id" {
    type = string
}

variable     "vpc_security_group_ids"{
    type = string
}  

variable "deployment_name" {
    type = string
}