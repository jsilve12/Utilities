resource "kubernetes_deployment" "lighthouse" {
  metadata {
    name = "lighthouse-api"
    labels = {
      app = "lighthouse-api"
    }
    namespace = "lighthouse"

    spec {
      replicas = 1

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
          container {
            name = "lighthouse-api"
            image = "gcr.io/"
          }
        }
      }
    }
  }
}
