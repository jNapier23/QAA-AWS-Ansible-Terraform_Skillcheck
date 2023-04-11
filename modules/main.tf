resource "aws_instance" "deployment" {
    ami                     = var.ami_id
    instance_type           = var.instance_type
    key_name                = var.ssh_key_name
    subnet_id               = var.subnet_id
    vpc_security_group_ids  = var.vpc_security_group_ids

    tags = {
        Name = var.deployment_name
    }
}