variable "ami_id" {
  type = string
}

variable "client_instance_type" {
  type = string
}

variable "name" {
  type = string
}

variable "client_count" {
  default = 0
  type    = number
}

variable "public_subnets" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "instance_profile_name" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "public_route53_zone_name" {
  type = string
}

variable "nomad_id" {
  type      = string
  sensitive = true
}

variable "nomad_token" {
  type      = string
  sensitive = true
}

variable "allow_internal_sg_id" {
  type = string
}
