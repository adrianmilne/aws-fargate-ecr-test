##############################################################
# NAT Gateway for private subnets outbound traffic
##############################################################

resource "aws_eip" "elastic_ip" {
  vpc = true

  tags = {
    Name = "Test-Elastic-IP"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = var.subnet_id

  tags = {
    Name = "Test-NAT-Gateway"
  }
}

resource "aws_route_table" "nat_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Test-NAT-RT"
  }
}

resource "aws_route_table_association" "route_table_association_nat" {
  route_table_id = aws_route_table.nat_route_table.id
  subnet_id      = var.subnet_id
}
