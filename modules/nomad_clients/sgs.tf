data "aws_ec2_managed_prefix_list" "cloud_front_prefix_list" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "instance_clients_ingress" {
  name   = "${var.name}-clients-ingress"
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_client_ingress.id]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_client_ingress.id]
  }
}

resource "aws_security_group" "lb_client_ingress" {
  name        = "lb-client-ingress"
  vpc_id      = var.vpc_id
  description = "Allow HTTPS access from the outside"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_lb_nomad" {
  security_group_id = aws_security_group.lb_client_ingress.id

  from_port      = 443
  ip_protocol    = "tcp"
  to_port        = 443
  prefix_list_id = data.aws_ec2_managed_prefix_list.cloud_front_prefix_list.id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_allow_internal" {
  security_group_id = aws_security_group.lb_client_ingress.id

  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  cidr_ipv4   = "10.0.0.0/8"

}

resource "aws_vpc_security_group_egress_rule" "egress_lb_nomad_all" {
  security_group_id = aws_security_group.lb_client_ingress.id
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}
