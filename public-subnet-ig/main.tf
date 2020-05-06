
provider "aws" {
  profile = "default"
  region  = "eu-west-2"

  assume_role {
    role_arn = TODO
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
  route_table_ids = [module.vpc.ig_route_table_id]
  #breaks it
  #route_table_ids = [module.vpc.main_route_table_id]
  private_dns_enabled = true
}

module "ecs" {
  source = "../modules/ecs"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id
  assign_public_ip = true
}

## This works!