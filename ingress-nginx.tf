/*
  Deploys an ingress-nginx controller as a DaemonSet via the host network as described here:
  https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#via-the-host-network

  Helm Chart: https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
  Values: https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml
*/
resource "helm_release" "ingress-nginx" {
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = "4.0.13"
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

  set {
    name  = "controller.ingressClassResource.default"
    value = true
  }
}
