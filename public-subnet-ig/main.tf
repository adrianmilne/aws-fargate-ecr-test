
##############################################################
# WORKS!
#
# Private Subnet
#   - X
# Public Subnet
#   - Internet Gateway
#   - ECS Fargate Task
##############################################################

provider "aws" {
  profile = "default"
  region  = "eu-west-2"

  assume_role {
    role_arn = var.role_arn
  }
}

module "vpc" {
  source               = "../modules/vpc"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "vpc-gw-ig" {
  source    = "../modules/vpc-gw-ig"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id
}

module "ecs" {
  source           = "../modules/ecs"
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_id
  assign_public_ip = true
}

## This works!
