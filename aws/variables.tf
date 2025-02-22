variable "name" {
  description = "Prefix used to name various infrastructure components. Alphanumeric characters only."
  default     = "nomad"
  type        = string
}

variable "ami_id" {
  type = string
}

variable "region" {
  description = "The AWS region to deploy to."
  type        = string
  default     = "eu-west-1"
}
