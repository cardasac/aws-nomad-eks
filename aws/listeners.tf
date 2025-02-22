resource "aws_lb_listener_rule" "forward_traefik_dashboard" {
  listener_arn = module.nomad_servers.lb_servers.https_listener

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik_target_group.arn
  }

  condition {
    host_header {
      values = ["traefik.${data.aws_route53_zone.primary_private.name}", ]
    }
  }
}

resource "aws_lb_listener_rule" "forward_traefik_http" {
  listener_arn = module.nomad_servers.lb_servers.https_listener

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik_http_target_group.arn
  }

  condition {
    host_header {
      values = [for subdomain in ["any-api"] : "${subdomain}.${data.aws_route53_zone.primary_private.name}"]
    }
  }
}

resource "aws_lb_listener_rule" "forward_ui_nomad" {
  listener_arn = module.nomad_servers.lb_servers.https_listener

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad_target_group.arn
  }

  condition {
    host_header {
      values = ["nomad.${data.aws_route53_zone.primary_private.name}"]
    }
  }
}

resource "aws_lb_listener_rule" "forward_consul_ui" {
  listener_arn = module.nomad_servers.lb_servers.https_listener

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_target_group.arn
  }

  condition {
    host_header {
      values = ["consul.${data.aws_route53_zone.primary_private.name}"]
    }
  }
}
