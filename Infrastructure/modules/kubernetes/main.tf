resource "kubernetes_namespace" "resume" {
  metadata {
    name = "resume"
  }
}
resource "kubernetes_namespace" "chess" {
  metadata {
    name = "chess"
  }
}
resource "kubernetes_namespace" "lighthouse" {
  metadata {
    name = "lighthouse"
  }
}
