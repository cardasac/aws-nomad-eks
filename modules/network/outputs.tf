output "vpc_id" {
  value = aws_vpc.base_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "private_route_table_id" {
  value = aws_route_table.private_route_table.id
}

output "allow_internal_sg_id" {
  value = aws_security_group.allow_all_internal.id
}

output "public_ip" {
  value = aws_eip.nat_gateway_ip.public_ip
}
