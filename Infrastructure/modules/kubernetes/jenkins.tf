resource "kubernetes_service" "jenkins" {
  metadata {
    name = "jenkins"
    labels = {
      app = "jenkins"
    }
  }
  spec {
    selector = {
      app = "jenkins"
      tier = "deploy"
    }
    port {
      port = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins_claim" {
  metadata {
    name      = "jenkins-claim"
    labels = {
      managedby = "terraform"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_deployment" "jenkins" {
  metadata {
    name = "jenkins"
    labels = {
      app = "jenkins"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jenkins"
        tier = "deploy"
      }
    }

    template {
      metadata {
        labels = {
          app = "jenkins"
          tier = "deploy"
        }
      }
      spec {
        container {
          name = "jenkins"
          image = "jenkins/jenkins:lts"
          resources {
            requests = {
              cpu = "1.0"
              memory = "1Gi"
            }
          }
          env {
            name = "DOCKER_HOST"
            value = "tcp://localhost:2375"
          }
          port {
            container_port = 8080
          }
          port {
            container_port = 50000
          }
          volume_mount {
            name = "jenkins-persistent"
            mount_path = "/var/jenkins_home"
          }
        }
        security_context {
          fs_group = "1000"
        }
        volume {
          name = "jenkins-persistent"
          persistent_volume_claim {
            claim_name = "jenkins-claim"
          }
        }
      }
    }
  }
}

resource "google_dns_record_set" "jenkins" {
  name = "jenkins.${var.root}"
  type = "A"
  ttl = 300
  managed_zone = var.zone
  rrdatas = [resource.kubernetes_service.jenkins.status[0].load_balancer[0].ingress[0].ip]
}
