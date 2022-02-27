terraform {
  required_providers {
    kubectl = {
      source = "alekc-forks/kubectl"
    }
  }
}

locals {
  namespace = var.namespace == null ? var.name : var.namespace
}

resource "kubectl_manifest" "application" {
  wait = true
  yaml_body = templatefile("${path.module}/manifests/application.yaml", {
    argocd     = var.argocd
    name       = var.name
    namespace  = local.namespace
    repository = var.repository
    path       = var.path
  })
}
