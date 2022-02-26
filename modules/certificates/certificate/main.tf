terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

locals {
  name = replace(var.domain, ".", "-")
}

/*
  Creates a wildcard certificate for erichaag.dev.
*/
resource "kubectl_manifest" "certificate" {
  yaml_body = templatefile("${path.module}/manifests/certificate.yaml", {
    domain    = var.domain
    issuer    = var.issuer
    name      = local.name
    namespace = var.install_namespace
  })
}
