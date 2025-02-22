data_dir   = "/opt/nomad/data"
region     = "eu"
datacenter = "AVAILABILITY_ZONE"

telemetry {
  disable_hostname           = true
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
}

acl {
  enabled = true
}

leave_on_terminate = true

server {
  enabled              = true
  bootstrap_expect     = SERVER_COUNT
  authoritative_region = "eu"
}

consul {
  address = "127.0.0.1:8500"
  token   = "CONSUL_TOKEN"
}

vault {
  enabled          = false
  address          = "http://active.vault.service.consul:8200"
  task_token_ttl   = "1h"
  create_from_role = "nomad-cluster"
  token            = ""
}
