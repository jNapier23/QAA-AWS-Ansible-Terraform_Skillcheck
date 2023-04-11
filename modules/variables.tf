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
    default = "${aws_subnet.subnet_B.id}"
}

variable     "vpc_security_group_ids"{
    default = ["${aws_security_group.project_sg.id}"]
}  

variable "deployment_name" {
    default = "${"deployment".instance_id}"
}