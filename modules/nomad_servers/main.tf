locals {
  retry_join = "provider=aws tag_key=ConsulAutoJoin tag_value=auto-join"
}

resource "aws_launch_template" "ec2_server_template" {
  name          = "server"
  image_id      = var.ami_id
  instance_type = var.server_instance_type
  vpc_security_group_ids = [
    aws_security_group.instance_servers_ingress.id, var.allow_internal_sg_id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 10
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        "Name" = "${var.name}-server"
      },
      {
        "ConsulAutoJoin" = "auto-join"
      },
      {
        "NomadType" = "server"
      }
    )
  }

  iam_instance_profile {
    name = var.instance_profile_name
  }

  ebs_optimized = true

  user_data = base64encode(templatefile("../modules/nomad_servers/scripts/user_data_server.sh", {
    server_count              = var.server_count
    retry_join                = local.retry_join
    nomad_consul_token_id     = var.nomad_id
    nomad_consul_token_secret = var.nomad_token
  }))
}

resource "aws_placement_group" "servers" {
  name     = "nomad-servers"
  strategy = "spread"
}

resource "aws_autoscaling_group" "server_group" {
  max_size                  = var.server_count
  min_size                  = 2
  desired_capacity          = 3
  health_check_grace_period = 300
  default_cooldown          = 15
  name                      = "server"
  placement_group           = aws_placement_group.servers.id

  vpc_zone_identifier = var.private_subnets
  health_check_type   = "ELB"

  instance_maintenance_policy {
    min_healthy_percentage = 50
    max_healthy_percentage = 100
  }

  launch_template {
    id      = aws_launch_template.ec2_server_template.id
    version = aws_launch_template.ec2_server_template.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      max_healthy_percentage = 100
    }
  }
}
