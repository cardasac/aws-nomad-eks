resource "aws_network_acl_rule" "deny_ssh" {
  network_acl_id = data.aws_network_acls.default_acls.ids[0]
  rule_number    = 1
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "deny_rdp" {
  network_acl_id = data.aws_network_acls.default_acls.ids[0]
  rule_number    = 2
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3389
  to_port        = 3389
}

data "aws_network_acls" "default_acls" {
  vpc_id = aws_vpc.base_vpc.id

  filter {
    name   = "default"
    values = ["true"]
  }
}
