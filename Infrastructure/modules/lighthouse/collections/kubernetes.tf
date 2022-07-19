resource "kubernetes_deployment" "collections_daemon" {
  metadata {
    name = "collections-daemon"
    labels = {
      app = "collections-daemon"
    }
    namespace = "lighthouse"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "collections-daemon"
        tier = "deploy"
      }
    }
    template {
      metadata {
        labels = {
          app = "collections-daemon"
          tier = "deploy"
        }
      }
      spec {
        container {
          name = "collections-daemon"
          image = var.image
          command = ["python3"]
          args = ["Collections/main.py"]
        }
      }
    }
  }
}
