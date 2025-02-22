resource "random_uuid" "nomad_id" {
}

resource "random_uuid" "nomad_token" {
}

module "setup" {
  source = "../modules/setup"
}

module "containers" {
  source = "../modules/containers"
}

data "aws_route53_zone" "primary_private" {
  name         = "${terraform.workspace}.${local.domain_name}"
  private_zone = true
}

data "aws_route53_zone" "primary_public" {
  name = "${terraform.workspace}.${local.domain_name}"
}

module "certificate_star_primary" {
  source          = "../modules/certificate"
  route53_zone_id = data.aws_route53_zone.primary_public.zone_id
  domain          = "*.${data.aws_route53_zone.primary_public.name}"
}
