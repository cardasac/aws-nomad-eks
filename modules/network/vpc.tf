resource "aws_vpc" "base_vpc" {
  cidr_block           = var.cidr_range
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "base-vpc"
  }
}

resource "aws_vpc_block_public_access_exclusion" "allow_bidirectional" {
  vpc_id                          = aws_vpc.base_vpc.id
  internet_gateway_exclusion_mode = "allow-bidirectional"
}

resource "aws_route53_zone_association" "secondary" {
  zone_id = var.zone_id
  vpc_id  = aws_vpc.base_vpc.id
}

resource "aws_default_security_group" "default_base" {
  vpc_id = aws_vpc.base_vpc.id

  tags = {
    Name = "default-sg"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.base_vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones   = data.aws_availability_zones.available.names
  private_subnets_cidr = [for i in range(length(local.availability_zones)) : cidrsubnet(aws_vpc.base_vpc.cidr_block, 8, 4 + i)]
}

resource "aws_subnet" "public_subnet" {
  count             = length(local.availability_zones)
  vpc_id            = aws_vpc.base_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.base_vpc.cidr_block, 8, count.index)
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "public-subnet-${local.availability_zones[count.index]}"
    Tier = "public"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.base_vpc.id
  count             = length(local.private_subnets_cidr)
  cidr_block        = element(local.private_subnets_cidr, count.index)
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name                                    = "private-subnet-${local.availability_zones[count.index]}"
    Tier                                    = "private"
    "kubernetes.io/role/internal-elb"       = 1
    "kubernetes.io/cluster/eks-obs-cluster" = "shared"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.base_vpc.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.private_route_table.id]
  tags = {
    Name = "base-s3-endpoint"
  }
}
