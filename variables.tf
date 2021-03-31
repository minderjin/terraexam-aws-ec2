variable "name" {}
variable "region" {}

variable "tags" {}

## Bastion
variable "bastion_instance_type" {}
variable "bastion_key_name" {}
variable "bastion_termination_protection" {}
variable "bastion_associate_public_ip_address" {}
variable "bastion_monitoring" {}
variable "bastion_cpu_credits" {}
variable "bastion_volume_size" {}

## WAS
variable "was_instance_type" {}
variable "was_key_name" {}
variable "was_termination_protection" {}
variable "was_associate_public_ip_address" {}
variable "was_monitoring" {}
variable "was_cpu_credits" {}
variable "was_volume_size" {}
