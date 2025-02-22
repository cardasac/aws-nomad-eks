resource "aws_lb" "nomad_servers_lb" {
  name                       = "${var.environment}-server-lb"
  load_balancer_type         = "application"
  security_groups            = [var.allow_internal_sg_id]
  drop_invalid_header_fields = true
  internal = true
  subnets = var.private_subnets
}
