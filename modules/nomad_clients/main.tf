locals {
  retry_join = "provider=aws tag_key=ConsulAutoJoin tag_value=auto-join"
}

resource "aws_launch_template" "ec2_client_template" {
  name          = "client"
  image_id      = var.ami_id
  instance_type = var.client_instance_type

  vpc_security_group_ids = [
    aws_security_group.instance_clients_ingress.id,
    var.allow_internal_sg_id
  ]

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_type           = "gp3"
      volume_size           = "8"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        "Name" = "${var.name}-client"
      },
      {
        "ConsulAutoJoin" = "auto-join"
      },
      {
        "NomadType" = "client"
      }
    )
  }

  iam_instance_profile {
    name = var.instance_profile_name
  }

  ebs_optimized = true

  user_data = base64encode(templatefile("../modules/nomad_clients/scripts/user_data_client.sh", {
    retry_join = local.retry_join
    nomad_consul_token_id     = var.nomad_id
    nomad_consul_token_secret = var.nomad_token
  }))
}

resource "aws_autoscaling_group" "client_group" {
  max_size                  = var.client_count
  min_size                  = var.client_count
  health_check_grace_period = 120
  default_cooldown          = 15
  name                      = "client"
  health_check_type         = "ELB"
  vpc_zone_identifier       = var.private_subnets

  launch_template {
    id      = aws_launch_template.ec2_client_template.id
    version = aws_launch_template.ec2_client_template.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
}
