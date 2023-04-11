resource "aws_instance" "deployment" {
    ami                     = var.ami_id
    instance_type           = var.instance_type
    key_name                = var.ssh_key_name
}