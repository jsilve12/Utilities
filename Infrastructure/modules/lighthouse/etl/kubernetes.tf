resource "kubernetes_deployment" "etl_daemon" {
  metadata {
    name = "etl-daemon"
    labels = {
      app = "etl-daemon"
    }
    namespace = "lighthouse"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "etl-daemon"
        tier = "deploy"
      }
    }
    template {
      metadata {
        labels = {
          app = "etl-daemon"
          tier = "deploy"
        }
      }
      spec {
        service_account_name = "lighthouse-iam"
        container {
          name = "etl-daemon"
          image = var.image
          command = ["python3"]
          args = ["ETL/main.py"]
        }
      }
    }
  }
}
