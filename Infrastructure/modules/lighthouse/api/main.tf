resource "kubernetes_deployment" "lighthouse" {
  metadata {
    name = "lighthouse-api"
    labels = {
      app = "lighthouse-api"
    }
    namespace = "lighthouse"
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "lighthouse-api"
        tier = "deploy"
      }
    }

    template {
      metadata {
        labels = {
          app = "lighthouse-api"
          tier = "deploy"
        }
      }
      spec {
        service_account_name = "lighthouse-iam"
        container {
          name = "lighthouse-api"
          image = var.image
          port {
            container_port = 8000
          }
          command = ["uvicorn"]
          args = ["API.api:APP", "--host", "0.0.0.0"]
        }
      }
    }
  }
}

resource "kubernetes_service" "lighthouse" {
  metadata {
    name = "lighthouse-api"
    labels = {
      app = "lighthouse-api"
    }
    namespace = "lighthouse"
  }
  spec {
    selector = {
      app = "lighthouse-api"
      tier = "deploy"
    }
    port {
      port = 80
      target_port = 8000
    }
    type = "LoadBalancer"
  }
}

resource "google_dns_record_set" "lighthouse" {
  name = "lighthouse.${var.root}"
  type = "A"
  ttl = 300
  managed_zone = var.zone
  rrdatas = [resource.kubernetes_service.lighthouse.status[0].load_balancer[0].ingress[0].ip]
}
