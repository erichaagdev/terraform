resource "helm_release" "ingress-nginx" {
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = "3.35.0"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.service.nodePorts.http"
    value = 32080
  }

  set {
    name  = "controller.service.nodePorts.https"
    value = 32443
  }

  set {
    name  = "controller.service.nodePorts.tcp.8080"
    value = 32808
  }
}

resource "null_resource" "assign-internal-ip" {
  triggers = {
    ingress_nginx     = helm_release.ingress-nginx.id
    primary_node_pool = google_container_node_pool.primary-node-pool.id
  }
  provisioner "local-exec" {
    command = "/bin/sh assign-internal-ip.sh ${var.cluster-name} ${data.google_client_config.current.zone}"
  }
}
