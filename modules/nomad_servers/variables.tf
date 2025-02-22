variable "ami_id" {
  type = string
}

variable "server_instance_type" {
  type = string
}

variable "name" {
  type = string
}

variable "server_count" {
  default = 3
  type    = number
}

variable "private_subnets" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "certificate_arn" {
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
