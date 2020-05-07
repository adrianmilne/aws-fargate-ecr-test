##############################################################
# VPC
##############################################################
resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/16"
  # The 2 below must be set to true if 'private_dns_enabled' is set to true for the VPC interface endpoints
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = "default"

  tags = {
    Name = "Test-VPC"
  }
}

##############################################################
# Subnets
##############################################################
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Test-Public-Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Test-Private-Subnet"
  }
}





##############################################################
# Routing Tables
##############################################################

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "Test-Main-RT"
  }
}





##############################################################
# Routing Table/Subnet associations
##############################################################
resource "aws_main_route_table_association" "route_table_association_main" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.main_route_table.id
}

