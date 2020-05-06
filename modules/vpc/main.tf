##############################################################
# VPC
##############################################################
resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/16"
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
# Internet Gateway
##############################################################

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Test-Internet-Gateway"
  }
}

##############################################################
# Elastic IP's for NAT
##############################################################

resource "aws_eip" "elastic_ip" {
  vpc = true

  tags = {
    Name = "Test-Elastic-IP"
  }
}

##############################################################
# NAT Gateway for private subnets outbound traffic
# Availability Zone A only at the moment (no redundancy)
##############################################################

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = "Test-NAT-Gateway"
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

resource "aws_route_table" "nat_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Test-NAT-RT"
  }
}

resource "aws_route_table" "ig_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Test-IG-RT"
  }
}

##############################################################
# Routing Table/Subnet associations
##############################################################
resource "aws_main_route_table_association" "route_table_association_main" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "route_table_association_nat" {
  route_table_id = aws_route_table.nat_route_table.id
  subnet_id      = aws_subnet.private_subnet.id
}

resource "aws_route_table_association" "route_table_association_ig" {
  route_table_id = aws_route_table.ig_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}
