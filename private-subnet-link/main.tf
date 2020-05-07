##############################################################
#  Uses a VPC endpoint - so no need for IG or NAT
#  https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints.html


#
# Private Subnet
#   - ECS Fargate Task (no public IP)
#   - VPC Link
# Public Subnet
#   - X
##############################################################
provider "aws" {
  profile = "default"
  region  = "eu-west-2"

  assume_role {
    role_arn = var.role_arn
  }
}

module "vpc" {
  source = "../modules/vpc"
  enable_dns_hostnames = true
  enable_dns_support = true
}

module "vpc-link" {
  source = "../modules/vpc-link"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_id
  route_table_ids = [module.vpc.main_route_table_id]
  private_dns_enabled = true
}

module "ecs" {
  source           = "../modules/ecs"
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.private_subnet_id
  assign_public_ip = false
  #assign_public_ip = true - changing this to true makes no difference
}

## This does not work..
