resource "aws_security_group" "instance_servers_ingress" {
  name        = "${var.name}-ui-ingress"
  vpc_id      = var.vpc_id
  description = "Allow port 4646 from load balancer to launch templates (ec2)"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_nomad" {
  security_group_id = aws_security_group.instance_servers_ingress.id

  from_port                    = 4646
  ip_protocol                  = "tcp"
  to_port                      = 4646
  referenced_security_group_id = aws_security_group.lb_nomad_ui_ingress.id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_nomad_self" {
  security_group_id = aws_security_group.instance_servers_ingress.id

  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.instance_servers_ingress.id
}

resource "aws_vpc_security_group_ingress_rule" "egress_nomad_all" {
  security_group_id = aws_security_group.instance_servers_ingress.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_security_group" "lb_nomad_ui_ingress" {
  name        = "lb-${var.name}-ui-ingress"
  vpc_id      = var.vpc_id
  description = "Allow HTTPS access to server load balancer for accessing Nomad UI"
}

resource "aws_vpc_security_group_ingress_rule" "egress_lb_nomad_all" {
  security_group_id = aws_security_group.lb_nomad_ui_ingress.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}