resource "kubernetes_deployment" "lighthouse_daemon" {
  metadata {
    name = "lighthouse-daemon"
    labels = {
      app = "lighthouse-daemon"
    }
    namespace = "lighthouse"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "lighthouse-daemon"
        tier = "deploy"
      }
    }
    template {
      metadata {
        labels = {
          app = "lighthouse-daemon"
          tier = "deploy"
        }
      }
      spec {
        service_account_name = "lighthouse-iam"
        container {
          name = "lighthouse-daemon"
          image = var.image
          command = ["python3"]
          args = ["server.py"]
        }
      }
    }
  }
}
