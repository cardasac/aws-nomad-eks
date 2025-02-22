resource "aws_route53_record" "record_alias" {
  for_each = toset(var.route53_record_names)

  zone_id = var.route53_zone_id
  name    = "${each.value}.${var.route53_zone_name}"
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}
