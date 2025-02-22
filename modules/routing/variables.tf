variable "lb_dns_name" {
  type = string
}

variable "lb_zone_id" {
  type = string
}

variable "route53_zone_name" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "route53_record_names" {
  type = set(string)
}
