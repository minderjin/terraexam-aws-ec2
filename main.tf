provider "aws" {
  # profile = "default"
  region = var.region
}

# Workspace - vpc
data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "terraexam"
    workspaces = {
      name = "terraexam-aws-vpc"
    }
  }
}

# Workspace - security group
data "terraform_remote_state" "sg" {
  backend = "remote"
  config = {
    organization = "terraexam"
    workspaces = {
      name = "terraexam-aws-sg"
    }
  }
}

### Usage ###
#
# resource "aws_instance" "redis_server" {
#   # Terraform 0.12 syntax: use the "outputs.<OUTPUT NAME>" attribute
#   subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id

#   # Terraform 0.11 syntax: use the "<OUTPUT NAME>" attribute
#   subnet_id = "${data.terraform_remote_state.vpc.subnet_id}"
# }


# Resource - deafult security group
data "aws_security_group" "default" {
  name = "default"
  #   vpc_id = module.vpc.vpc_id
  vpc_id = local.vpc_id
}


locals {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id //"vpc-04bc8955784f0fa6d"
  vpc_cidr_block = data.terraform_remote_state.vpc.outputs.vpc_cidr_block //"10.0.0.0/16"
  bastion_security_group_ids = data.terraform_remote_state.sg.outputs.bastion_security_group_id  //["sg-0b28759a17906d1e8"]
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnets  //["subnet-0d731cbf3711d6ba5","subnet-092b6128a970b5666"]
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets  //["subnet-05f4aa0ef2c3d01eb","subnet-0324151bd7d5f1577"]
  database_subnet_ids = data.terraform_remote_state.vpc.outputs.database_subnets  //["subnet-042c5dad0a4d8d1a0","subnet-0cc660ffb3b50fcf2"]
}

module "bastion" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "${var.name}-bastion"
  instance_count         = 1

  ami                    = "ami-09c5e030f74651050"  // Amazon Linux 2
  instance_type          = "t2.micro"
  key_name               = "oregon-key"
  monitoring             = false
  
  vpc_security_group_ids = local.bastion_security_group_ids
  subnet_id              = local.public_subnet_ids[0]

  tags = var.tags
}