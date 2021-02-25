provider "aws" {
  # profile = "default"
  region = var.region
}

data "aws_security_group" "default" {
  name = "default"
  #   vpc_id = module.vpc.vpc_id
  vpc_id = local.vpc_id
}

locals {
  vpc_id = "vpc-04bc8955784f0fa6d"
  vpc_cidr_block = "10.0.0.0/16"
  bastion_security_group_ids = [""]
  public_subnet_ids = ["subnet-0d731cbf3711d6ba5","subnet-092b6128a970b5666"]
  private_subnet_ids = ["subnet-05f4aa0ef2c3d01eb","subnet-0324151bd7d5f1577"]
  database_subnet_ids = ["subnet-042c5dad0a4d8d1a0","subnet-0cc660ffb3b50fcf2"]
}

module "bastion" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "${var.name}-bastion"
  instance_count         = 1

  ami                    = "ami-0f9eefbab78499455"  // Amazon Linux 2
  instance_type          = "t3.micro"
  key_name               = "oregon-key"
  monitoring             = true
  vpc_security_group_ids = local.bastion_security_group_ids
  subnet_id              = local.public_subnet_ids[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}