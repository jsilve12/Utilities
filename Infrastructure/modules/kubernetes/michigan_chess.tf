resource "kubernetes_service" "umich" {
  metadata {
    name = "chess-website"
    labels = {
      app = "chess-website"
    }
    namespace = "chess"
  }
  spec {
    selector = {
      app = "chess-website"
      tier = "deploy"
    }
    port {
      port = 80
      target_port = 8000
    }
    type = "LoadBalancer"
  }
}

resource "google_dns_record_set" "umich" {
  name = "umich.chess.${var.root}"
  type = "A"
  ttl = 300
  managed_zone = var.zone
  rrdatas = [resource.kubernetes_service.umich.status[0].load_balancer[0].ingress[0].ip]
}

resource "kubernetes_deployment" "umich" {
  metadata {
    name = "chess-website"
    labels = {
      app = "chess-website"
    }
    namespace = "chess"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "chess-website"
        tier = "deploy"
      }
    }

    template {
      metadata {
        labels = {
          app = "chess-website"
          tier = "deploy"
        }
      }
      spec {
        container {
          name = "chess-website"
          image = "gcr.io/personal-project-289714/chess-website:758179496"
          port {
            container_port = 8000
          }
        }
      }
    }
  }
}
