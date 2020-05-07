##############################################################
# Internet Gateway & Route Table
##############################################################

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Test-Internet-Gateway"
  }
}

resource "aws_route_table" "ig_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Test-IG-RT"
  }
}

resource "aws_route_table_association" "route_table_association_ig" {
  route_table_id = aws_route_table.ig_route_table.id
  subnet_id      = var.subnet_id
}
