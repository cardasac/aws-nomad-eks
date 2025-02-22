variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "zone_id" {
  description = "Route53 zone ID"
  type        = string
}

variable "cidr_range" {
  description = "CIDR range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
