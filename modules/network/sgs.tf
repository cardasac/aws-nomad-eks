resource "aws_security_group" "allow_all_internal" {
  name        = "${var.environment}-allow-all-internal"
  vpc_id      = aws_vpc.base_vpc.id
  description = "Allow all internal traffic"

  tags = {
    Name = "allow-all-internal"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_allow_self" {
  security_group_id            = aws_security_group.allow_all_internal.id
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.allow_all_internal.id
}

resource "aws_vpc_security_group_egress_rule" "egress_allow_self" {
  security_group_id            = aws_security_group.allow_all_internal.id
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.allow_all_internal.id
}


resource "aws_vpc_security_group_ingress_rule" "ingress_allow_private" {
  security_group_id = aws_security_group.allow_all_internal.id
  ip_protocol       = "-1"
  cidr_ipv4         = "10.0.0.0/8"
}

resource "aws_vpc_security_group_egress_rule" "egress_allow_private" {
  security_group_id = aws_security_group.allow_all_internal.id
  ip_protocol       = "-1"
  cidr_ipv4         = "10.0.0.0/8"
}

resource "aws_vpc_security_group_egress_rule" "egress_allow_all" {
  security_group_id = aws_security_group.allow_all_internal.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
