packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "account_id" {
  type = string
}

data "amazon-ami" "hashistack" {
  filters = {
    architecture        = "arm64"
    name                = "al2023-ami-2023.*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = var.region
}

source "amazon-ebs" "hashistack" {
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/Terraform"
    session_name = "packer_build"
    external_id  = "terraform"
  }
  region                = var.region
  ssh_username          = "ec2-user"
  force_deregister      = true
  force_delete_snapshot = true
  imds_support          = "v2.0"
  ssh_interface         = "session_manager"
  iam_instance_profile = "packer-instance-profile"

  security_group_filter {
    filters = {
      "tag:Name" : "allow-all-internal"
    }
  }

  vpc_filter {
    filters = {
      "isDefault" : "false"
      "tag:Name" : "base-vpc"
    }
  }

  subnet_filter {
    filters = {
      "tag:Name" : "private-subnet-**"
    }
    most_free = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    delete_on_termination = true
    volume_size           = 8
  }

  snapshot_tags = {
    Name = "nomad-alb"
  }
}

build {
  name = "alb_arm64"
  source "source.amazon-ebs.hashistack" {
    ami_name      = "alb-${local.timestamp}"
    instance_type = "t4g.medium"
    source_ami    = "${data.amazon-ami.hashistack.id}"

    tags = {
      Name          = "nomad-alb"
      OS_Version    = "al2023"
      Release       = "Latest"
      Base_AMI_ID   = "{{ .SourceAMI }}"
      Base_AMI_Name = "{{ .SourceAMIName }}"
    }
  }

  provisioner "file" {
    source      = "../shared/scripts/install.yaml"
    destination = "install.yaml"
  }

  provisioner "shell" {
    inline = [
      "sudo dnf install -y ansible-core",
      "sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo",
      "ansible-playbook install.yaml"
    ]
  }

  provisioner "file" {
    destination = "/ops"
    source      = "../shared"
  }
}
