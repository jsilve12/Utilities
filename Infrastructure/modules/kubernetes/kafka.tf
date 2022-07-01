resource "kubernetes_persistent_volume_claim" "kafka_claim" {
  metadata {
    name      = "kafka-claim"
    labels = {
      managedby = "terraform"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "25Gi"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_deployment" "kafka" {
  metadata {
    name = "kafka"
    labels = {
      app = "kafka"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kafka"
        tier = "support"
      }
    }
    template {
      metadata {
        labels = {
          app = "kafka"
          tier = "support"
        }
      }
      spec {
        container {
          name = "kafka"
          image = "bitnami/kafka:latest"
          port {
            container_port = 9092
          }
          volume_mount {
            name = "kafka-persistent"
            mount_path = "/var/lib/kafka/data"
          }
        }
        security_context {
          fs_group = "1001"
        }
        volume {
          name = "kafka-persistent"
          persistent_volume_claim {
            claim_name = "kafka-claim"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kafka" {
  metadata {
    name = "kafka"
    labels = {
      app = "kafka"
    }
  }
  spec {
    selector = {
      app = "kafka"
      tier = "deploy"
    }
    port {
      port = 80
      target_port = 9092
    }
    type = "LoadBalancer"
  }
}

resource "google_dns_record_set" "kafka" {
  name = "kafka.${var.root}"
  type = "A"
  ttl = 300
  managed_zone = var.zone
  rrdatas = [resource.kubernetes_service.kafka.status[0].load_balancer[0].ingress[0].ip]
}
