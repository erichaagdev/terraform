# https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
resource "helm_release" "ingress-nginx" {
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = "4.0.9"
  create_namespace = true

  depends_on = [google_container_node_pool.primary-node-pool]

  set {
    name  = "controller.hostNetwork"
    value = true
  }

  set {
    name  = "controller.hostPort.enabled"
    value = true
  }

  set {
    name  = "controller.kind"
    value = "DaemonSet"
  }

  set {
    name  = "controller.reportNodeInternalIp"
    value = true
  }

  set {
    name  = "controller.service.enabled"
    value = false
  }

  set {
    name  = "controller.admissionWebhooks.enabled"
    value = false
  }
}
