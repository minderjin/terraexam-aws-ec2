provider "aws" {
  # profile = "default"
  region = var.region
}

## Another Workspaces ##
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


## Usage ##
# resource "aws_instance" "redis_server" {
#   # Terraform 0.12 syntax: use the "outputs.<OUTPUT NAME>" attribute
#   subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id

#   # Terraform 0.11 syntax: use the "<OUTPUT NAME>" attribute
#   subnet_id = "${data.terraform_remote_state.vpc.subnet_id}"
# }


locals {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets
  database_subnet_ids = data.terraform_remote_state.vpc.outputs.database_subnets

  bastion_security_group_ids = ["${data.terraform_remote_state.sg.outputs.bastion_security_group_id}"]
  alb_security_group_ids = ["${data.terraform_remote_state.sg.outputs.alb_security_group_id}"]
  was_security_group_ids = ["${data.terraform_remote_state.sg.outputs.was_security_group_id}"]
  db_security_group_ids = ["${data.terraform_remote_state.sg.outputs.db_security_group_id}"]
}

resource "aws_eip" "bastion" {
  count = 1
  vpc = true
  instance = module.bastion.id[0]
  
  tags = var.tags
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
  
  associate_public_ip_address = true
  
  tags = var.tags
}
