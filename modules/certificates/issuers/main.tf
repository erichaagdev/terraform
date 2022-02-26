terraform {
  required_providers {
    google = {
      source = "hashicorp/google-beta"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

data "google_client_config" "default" {}

resource "kubernetes_namespace" "certificates" {
  metadata {
    name = var.install_namespace
  }
}

/*
  Creates certificate issuers in the install namespace.
*/
resource "kubectl_manifest" "certificate-issuer-staging" {
  yaml_body = templatefile("${path.module}/manifests/issuer-staging.yaml", {
    email     = var.email
    namespace = kubernetes_namespace.certificates.metadata[0].name
    project   = data.google_client_config.default.project
  })
}

resource "kubectl_manifest" "certificate-issuer" {
  yaml_body = templatefile("${path.module}/manifests/issuer.yaml", {
    email     = var.email
    namespace = kubernetes_namespace.certificates.metadata[0].name
    project   = data.google_client_config.default.project
  })
}
