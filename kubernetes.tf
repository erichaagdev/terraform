provider "kubernetes" {
  host  = google_container_cluster.cluster.endpoint
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = google_container_cluster.cluster.endpoint
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
    )
  }
}

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

resource "kubernetes_namespace" "example-namespace" {
  metadata {
    name = "test"
  }
}

resource "null_resource" "assign-internal-ip" {
  provisioner "local-exec" {
    command = "/bin/sh assign-internal-ip.sh ${helm_release.ingress-nginx.name} ${google_container_node_pool.primary-node-pool.name}"
  }
}