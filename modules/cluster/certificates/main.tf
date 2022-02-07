terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

/*
  Creates certificates Kubernetes namespace.
*/
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
    project   = var.project
  })
}

resource "kubectl_manifest" "certificate-issuer" {
  yaml_body = templatefile("${path.module}/manifests/issuer.yaml", {
    namespace = kubernetes_namespace.certificates.metadata[0].name
    project   = var.project
  })
}

/*
  Creates a wildcard certificate for erichaag.dev.
*/
resource "kubectl_manifest" "certificate" {
  yaml_body = templatefile("${path.module}/manifests/certificate.yaml", {
    namespace = kubernetes_namespace.certificates.metadata[0].name
  })
}
