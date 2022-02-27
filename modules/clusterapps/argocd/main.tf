terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
    }
    kubectl = {
      source = "alekc-forks/kubectl"
    }
  }
}

locals {
  version = "v2.2.5"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

data "http" "argocd" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/${local.version}/manifests/core-install.yaml"
}

data "kubectl_file_documents" "argocd" {
  content = data.http.argocd.body
}

resource "kubectl_manifest" "argocd" {
  //noinspection HILUnresolvedReference
  for_each = data.kubectl_file_documents.argocd.manifests

  wait               = true
  yaml_body          = each.value
  override_namespace = kubernetes_namespace.argocd.metadata[0].name
}
