terraform {
  required_providers {
    google = {
      source = "hashicorp/google-beta"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

data "google_client_config" "default" {}

resource "kubernetes_namespace" "certificates" {
  metadata {
    name = "certificates"
  }
}

/*
  Creates a certificate issuer in the certificates namespace.
*/
resource "kubectl_manifest" "certificate-issuer-staging" {
  yaml_body = templatefile("${path.module}/manifests/issuer-staging.yaml", {
    namespace = kubernetes_namespace.certificates.metadata[0].name
    project   = data.google_client_config.default.project
  })
}

resource "kubectl_manifest" "certificate-issuer" {
  yaml_body = templatefile("${path.module}/manifests/issuer.yaml", {
    namespace = kubernetes_namespace.certificates.metadata[0].name
    project   = data.google_client_config.default.project
  })
}

/*
  Creates a wildcard certificate for erichaag.dev.
*/
resource "kubectl_manifest" "certificate" {
  yaml_body = templatefile("${path.module}/manifests/certificate-staging.yaml", {
    namespace = kubernetes_namespace.certificates.metadata[0].name
  })
}
