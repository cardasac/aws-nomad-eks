job "any-api" {
  type     = "service"
  priority = 60

  group "any-api" {
    network {
      port "any-api" {
        to = 8000
      }
    }

    service {
      name     = "any-api"
      port     = "any-api"
      provider = "consul"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.api.entrypoints=web",
        "traefik.http.routers.api.rule=Host(`<host>`)",
      ]
    }

    task "any-api" {
      driver = "docker"
      resources {
        cpu    =
        memory =
      }

      config {
        auth_soft_fail = true
        image          = "any-api"
        ports          = ["any-api"]
        labels {
          service_name = "any-api"
        }
      }
    }
  }
}
