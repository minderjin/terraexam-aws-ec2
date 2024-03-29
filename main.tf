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
#   # Terraform 0.12 syntax: use the "outputs.<OUTPUT NAME>" attribute
#   subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id
#
#   # Terraform 0.11 syntax: use the "<OUTPUT NAME>" attribute
#   subnet_id = "${data.terraform_remote_state.vpc.subnet_id}"


## EC2 AMI ##
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

locals {
  user_data = <<EOF
#!/bin/bash
echo "Hello Terraform!"
yum -y update
EOF

  was_user_data = <<EOF
#include https://go.aws/38GIqcB
EOF
}

locals {
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block      = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  public_subnet_ids   = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnet_ids  = data.terraform_remote_state.vpc.outputs.private_subnets
  database_subnet_ids = data.terraform_remote_state.vpc.outputs.database_subnets

  bastion_security_group_ids = [data.terraform_remote_state.sg.outputs.bastion_security_group_id]
  alb_security_group_ids     = [data.terraform_remote_state.sg.outputs.alb_security_group_id]
  was_security_group_ids     = [data.terraform_remote_state.sg.outputs.was_security_group_id]
  db_security_group_ids      = [data.terraform_remote_state.sg.outputs.db_security_group_id]
}

resource "aws_eip" "bastion" {
  count    = 1
  vpc      = true
  instance = module.bastion.id[0]

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-bastion"
    }
  )
}

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  instance_count = 1

  name = "${var.name}-bastion"
  ami  = data.aws_ami.amazon_linux.id //"ami-09c5e030f74651050" //Amazon Linux 2 

  instance_type               = var.bastion_instance_type
  key_name                    = var.bastion_key_name
  disable_api_termination     = var.bastion_termination_protection
  associate_public_ip_address = var.bastion_associate_public_ip_address
  monitoring                  = var.bastion_monitoring
  cpu_credits                 = var.bastion_cpu_credits

  # subnet_id                   = local.public_subnets[0]
  subnet_ids             = local.public_subnet_ids
  vpc_security_group_ids = local.bastion_security_group_ids
  user_data_base64       = base64encode(local.user_data)

  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = var.bastion_volume_size
      delete_on_termination = true
    },
  ]
  
  # ebs_block_device = [
  #   {
  #     device_name = "/dev/sdf"
  #     volume_type = "gp3"
  #     volume_size = 10
  #     encrypted   = true
  #     kms_key_id  = aws_kms_key.this.arn
  #   }
  # ]

  tags = var.tags
}

module "was" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  instance_count = 1

  name = "${var.name}-was"
  ami  = data.aws_ami.amazon_linux.id //"ami-09c5e030f74651050" //Amazon Linux 2 

  instance_type               = var.was_instance_type
  key_name                    = var.was_key_name
  disable_api_termination     = var.was_termination_protection
  associate_public_ip_address = var.was_associate_public_ip_address
  monitoring                  = var.was_monitoring
  cpu_credits                 = var.was_cpu_credits

  subnet_ids             = local.private_subnet_ids
  vpc_security_group_ids = local.was_security_group_ids
  user_data_base64       = base64encode(local.was_user_data)

  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = var.was_volume_size
      delete_on_termination = true
    },
  ]

  # ebs_block_device = [
  #   {
  #     device_name = "/dev/sdf"
  #     volume_type = "gp3"
  #     volume_size = 10
  #     encrypted   = true
  #     kms_key_id  = aws_kms_key.this.arn
  #   }
  # ]

  tags = var.tags
}
