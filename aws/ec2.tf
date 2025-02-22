data "aws_ami" "al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "random_shuffle" "subnets" {
  input        = module.network.private_subnet_ids
  result_count = 1
}

resource "aws_instance" "k6_nomad" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t4g.small"
  vpc_security_group_ids      = [module.network.allow_internal_sg_id]
  subnet_id                   = random_shuffle.subnets.result[0]
  user_data                   = file("data.sh")
  associate_public_ip_address = false

  tags = {
    Name = "k6-nomad"
  }
}

resource "aws_instance" "k6_eks" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t4g.small"
  vpc_security_group_ids      = [module.network.allow_internal_sg_id]
  subnet_id                   = random_shuffle.subnets.result[0]
  user_data                   = file("data.sh")
  associate_public_ip_address = false

  tags = merge(aws_servicecatalogappregistry_application.nomad_app.application_tag, {
    Name = "k6-eks"
  })
}
