resource "aws_lb_listener_rule" "private_forward_traefik" {
  listener_arn = aws_lb_listener.https_client_listener.id

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik_target_group.arn
  }

  condition {
    host_header {
      values = ["traefik.${var.public_route53_zone_name}"]
    }
  }
}

resource "aws_lb_listener" "https_client_listener" {
  load_balancer_arn = aws_lb.nomad_clients_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "503"
    }
  }
}
