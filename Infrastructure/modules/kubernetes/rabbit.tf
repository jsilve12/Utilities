resource "helm_release" "rabbitmq" {
  name = "rabbitmq"
  repository = "https://charts.bitnami.com/bitnami/charts"
  chart = "rabbitmq"
  set {
    name = "auth.password"
    value = "password"
  }
  set {
    name = "auth.username"
    value = "username"
  }
  set {
    name = "service.type"
    value = "LoadBalancer"
  }
  set {
    name = "auth.erlangCookie"
    value = "secretcookie"
  }
}
