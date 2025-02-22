resource "aws_nat_gateway" "public_nat_gateway" {
  allocation_id = aws_eip.nat_gateway_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_gateway_ip" {
  depends_on = [aws_internet_gateway.igw]
  domain     = "vpc"
  tags = {
    "Name" = "base-nat-gateway-ip"
  }
}
