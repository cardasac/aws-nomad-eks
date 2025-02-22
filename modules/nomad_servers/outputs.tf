output "lb_servers" {
  value = {
    dns_name       = aws_lb.nomad_servers_lb.dns_name
    zone_id        = aws_lb.nomad_servers_lb.zone_id
    arn            = aws_lb.nomad_servers_lb.arn
    https_listener = aws_lb_listener.https_listener.id
  }
}

output "auto_scalling_group" {
  value = aws_autoscaling_group.server_group.id
}
