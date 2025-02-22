job "app-proxy" {
  type     = "system"
  priority = 100

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  constraint {
    attribute = "${attr.platform.aws.instance-life-cycle}"
    value     = "on-demand"
  }

  update {
    max_parallel = 1
    stagger      = "5s"
  }

  group "entrypoints" {
    network {
      port "http" {
        static = 80
      }
      port "http_secure" {
        static = 443
      }
      port "admin" {
        static = 8080
      }
    }

    task "traefik" {
      service {
        name     = "traefik-https"
        provider = "consul"
        port     = "http_secure"

        check {
          name     = "alive"
          type     = "http"
          port     = "admin"
          interval = "10s"
          timeout  = "2s"
          path     = "/ping"
        }
      }

      service {
        name     = "traefik-http"
        provider = "consul"
        port     = "http"

        check {
          name     = "alive"
          type     = "http"
          port     = "admin"
          interval = "10s"
          timeout  = "2s"
          path     = "/ping"
        }

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.dashboard.rule=Host(`traefik-http.service.consul`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))",
          "traefik.http.routers.dashboard.service=api@internal"
        ]
      }

      resources {
        cpu    = 200
        memory = 256
      }

      identity {
        env         = true
        change_mode = "restart"
      }

      driver = "docker"

      env {
        AWS_REGION = "eu-west-1"
      }

      config {
        image          = "public.ecr.aws/docker/library/traefik:v3"
        auth_soft_fail = true
        network_mode   = "host"
        ports          = ["http", "http_secure", "admin"]
        args = [
          "--api=true",
          "--api.dashboard=true",
          "--api.insecure=true",

          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entryPoints.websecure.address=:${NOMAD_PORT_http_secure}",
          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",

          "--ping=true",
          "--providers.nomad=true",
          "--providers.nomad.defaultRule=Host(`{{ .Name }}.nomad.localhost`)",
          "--providers.nomad.endpoint.address=http://${NOMAD_IP_http_secure}:4646",
          "--providers.consul.endpoints=127.0.0.1:8500",
          "--providers.consulcatalog=true",
          "--providers.consulcatalog.exposedByDefault=false",
          "--providers.consulcatalog.defaultRule=Host(`{{ .Name }}.service.consul`)",

          "--accesslog=true",
          "--metrics.otlp=true",
          "--metrics.otlp.http=true",
          "--tracing.otlp.http=true",
          "--tracing.addinternals",
          "--tracing.otlp.http.endpoint=http://localhost:4318",
          "--metrics.otlp.http.endpoint=http://localhost:4318",
        ]
      }
    }
  }
}
