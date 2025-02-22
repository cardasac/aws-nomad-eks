resource "aws_lb" "nomad_clients_lb" {
  name                       = "${var.environment}-client-lb"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_client_ingress.id]
  subnets                    = var.public_subnets
  drop_invalid_header_fields = true
}
