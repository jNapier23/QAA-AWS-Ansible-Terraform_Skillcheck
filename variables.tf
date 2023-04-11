variable "access_key" {
    type = string
}

variable "secret_key" {
    type = string
}

variable "ssh_key_name" {
    default = "sshKey"
}

variable "ami_id" {
    default = "ami-061fbd84f343c52d5"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "subnet_id" {
    type = number
}

variable     "vpc_security_group_ids"{
    type = number
}  

variable "deployment_name" {
    type = string
}