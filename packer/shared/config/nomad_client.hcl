data_dir   = "/opt/nomad/data"
region     = "eu"
datacenter = "AVAILABILITY_ZONE"

acl {
  enabled = true
}

telemetry {
  disable_hostname           = true
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
}

leave_on_terminate = true

client {
  enabled = true
}

plugin "docker" {
  config {
    volumes {
      enabled = true
    }

    auth {
      helper = "ecr-login"
    }

    allow_privileged = true
  }
}

vault {
  enabled = true
  address = "http://active.vault.service.consul:8200"
}

consul {
  address = "127.0.0.1:8500"
  token   = "CONSUL_TOKEN"
}
