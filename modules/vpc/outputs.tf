output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "main_route_table_id" {
  value = aws_route_table.main_route_table.id
}

output "ig_route_table_id" {
  value = aws_route_table.ig_route_table.id
}

output "nat_route_table_id" {
  value = aws_route_table.nat_route_table.id
}
