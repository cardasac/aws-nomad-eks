variable "mimir_user" {
  description = "Mimir user"
  type        = string
  default     = ""
}

variable "grafana_cloud_token" {
  description = "Grafana cloud token for alloy"
  type        = string
}

job "monitor" {
  type     = "system"
  priority = 90

  update {
    max_parallel = 1
    stagger      = "5s"
  }

  group "agents" {
    network {
      port "grafana" {
        static = 12345
      }
    }

    task "grafana-alloy" {
      service {
        name     = "grafana-alloy-dashboard"
        port     = "grafana"
        provider = "consul"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "5s"

          check_restart {
            limit           = 3
            grace           = "5s"
            ignore_warnings = false
          }
        }
      }

      resources {
        cpu    = 50
        memory = 164
      }

      driver = "docker"

      template {
        data        = file("config.alloy")
        destination = "local/config.alloy"
      }

      env {
        mimir_user             = var.mimir_user
        GCLOUD_RW_API_KEY      = var.grafana_cloud_token
      }

      config {
        auth_soft_fail = true
        privileged     = true
        volumes        = ["/var/run/docker.sock:/var/run/docker.sock"]
        pid_mode       = "host"
        network_mode   = "host"
        labels = {
          app = "alloy"
        }

        image = "grafana/alloy:latest"
        ports = ["grafana"]
        args = [
          "run", "--server.http.listen-addr=0.0.0.0:12345", "--cluster.enabled",
          "--cluster.discover-peers",
          "provider=aws region=eu-west-1 addr_type=private_v4 tag_key=Name tag_value=nomad-client",
          "--cluster.advertise-interfaces", "ens5", "--stability.level=public-preview",
          "local/config.alloy"
        ]
      }
    }
  }
}
