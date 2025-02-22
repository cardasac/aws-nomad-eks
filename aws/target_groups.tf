resource "aws_lb_target_group" "nomad_target_group" {
  name     = "nomad-lb-tg"
  port     = 4646
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id
  health_check {
    enabled = true
    path    = "/v1/status/leader"
  }
}

resource "aws_lb_target_group" "consul_target_group" {
  name     = "consul-lb-tg"
  port     = 8500
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id
  health_check {
    enabled = true
    path    = "/ui/"
  }
}

resource "aws_lb_target_group" "traefik_target_group" {
  name     = "traefik-dashboard-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id
  health_check {
    enabled = true
    path    = "/dashboard"
  }
}

resource "aws_lb_target_group" "traefik_http_target_group" {
  name     = "traefik-http-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id
  health_check {
    enabled = true
    path    = "/dashboard"
    port    = 8080
  }
}

resource "aws_autoscaling_attachment" "target_group_nomad" {
  autoscaling_group_name = module.nomad_servers.auto_scalling_group
  lb_target_group_arn    = aws_lb_target_group.nomad_target_group.arn
}

resource "aws_autoscaling_attachment" "target_group_consul" {
  autoscaling_group_name = module.nomad_servers.auto_scalling_group
  lb_target_group_arn    = aws_lb_target_group.consul_target_group.arn
}

resource "aws_autoscaling_attachment" "target_group_traefik" {
  autoscaling_group_name = module.nomad_clients.auto_scalling_group
  lb_target_group_arn    = aws_lb_target_group.traefik_target_group.arn
}

resource "aws_autoscaling_attachment" "target_group_traefik_http" {
  autoscaling_group_name = module.nomad_clients.auto_scalling_group
  lb_target_group_arn    = aws_lb_target_group.traefik_http_target_group.arn
}
