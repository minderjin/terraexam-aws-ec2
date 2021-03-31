###############################################################################################################################################################################
# Terraform loads variables in the following order, with later sources taking precedence over earlier ones:
# 
# Environment variables
# The terraform.tfvars file, if present.
# The terraform.tfvars.json file, if present.
# Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames.
# Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)
###############################################################################################################################################################################
#
# terraform cloud 와 별도로 동작
# terraform cloud 의 variables 와 동등 레벨
#
# Usage :
#
#   terraform apply -var-file=terraform.tfvars
#
#
# [Terraform Cloud] Environment Variables
#
#     AWS_ACCESS_KEY_ID
#     AWS_SECRET_ACCESS_KEY 
#

name   = "example"
region = "us-west-2"

tags = {
  Terraform   = "true"
  Environment = "dev"
}

## Bastion
bastion_instance_type               = "t3.micro"
bastion_key_name                    = "ssh-key"
bastion_termination_protection      = false
bastion_associate_public_ip_address = true
bastion_monitoring                  = false
bastion_cpu_credits                 = "unlimited"
bastion_volume_size                 = 8

## WAS
was_instance_type               = "t3.micro"
was_key_name                    = "ssh-key"
was_termination_protection      = false
was_associate_public_ip_address = false
was_monitoring                  = true
was_cpu_credits                 = "unlimited"
was_volume_size                 = 10