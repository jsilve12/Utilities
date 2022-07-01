resource "kubernetes_service" "resume" {
  metadata {
    name = "resume-website"
    labels = {
      app = "resume-website"
    }
    namespace = "resume"
  }
  spec {
    selector = {
      app = "website"
      tier = "deploy"
    }
    port {
      port = 80
      target_port = 8000
    }
    type = "LoadBalancer"
  }
}

resource "google_dns_record_set" "resume" {
  name = "${var.root}"
  type = "A"
  ttl = 300
  managed_zone = var.zone
  rrdatas = [resource.kubernetes_service.resume.status[0].load_balancer[0].ingress[0].ip]
}

resource "kubernetes_deployment" "resume" {
  metadata {
    name = "website"
    labels = {
      app = "website"
    }
    namespace = "resume"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "website"
        tier = "deploy"
      }
    }

    template {
      metadata {
        labels = {
          app = "website"
          tier = "deploy"
        }
      }
      spec {
        container {
          name = "website"
          image = "gcr.io/personal-project-289714/resume:233739481"
          port {
            container_port = 8000
          }
        }
      }
    }
  }
}
