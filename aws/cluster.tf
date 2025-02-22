module "network" {
  source      = "../modules/network"
  region      = var.region
  environment = terraform.workspace
  zone_id     = data.aws_route53_zone.primary_private.zone_id
}

module "nomad_servers" {
  source                = "../modules/nomad_servers"
  name                  = var.name
  vpc_id                = module.network.vpc_id
  private_subnets       = module.network.private_subnet_ids
  ami_id                = var.ami_id
  environment           = terraform.workspace
  server_count          = 3
  server_instance_type  = "t4g.nano"
  instance_profile_name = "nomad-instance-profile"
  certificate_arn       = module.certificate_star_primary.certificate_arn
  nomad_id              = random_uuid.nomad_id.result
  nomad_token           = random_uuid.nomad_token.result
  allow_internal_sg_id  = module.network.allow_internal_sg_id
}

module "nomad_clients" {
  source                   = "../modules/nomad_clients"
  name                     = var.name
  vpc_id                   = module.network.vpc_id
  private_subnets          = module.network.private_subnet_ids
  public_subnets           = module.network.public_subnet_ids
  ami_id                   = var.ami_id
  environment              = terraform.workspace
  client_count             = 0
  client_instance_type     = "t4g.small"
  instance_profile_name    = "nomad-instance-profile"
  certificate_arn          = module.certificate_star_primary.certificate_arn
  public_route53_zone_name = data.aws_route53_zone.primary_public.name
  nomad_id                 = random_uuid.nomad_id.result
  nomad_token              = random_uuid.nomad_token.result
  allow_internal_sg_id     = module.network.allow_internal_sg_id
}

module "routing_private" {
  source               = "../modules/routing"
  route53_record_names = ["nomad", "consul", "traefik", "any-api"]
  lb_dns_name          = module.nomad_servers.lb_servers.dns_name
  lb_zone_id           = module.nomad_servers.lb_servers.zone_id
  route53_zone_id      = data.aws_route53_zone.primary_private.zone_id
  route53_zone_name    = data.aws_route53_zone.primary_private.name
}
