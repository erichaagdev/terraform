terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_namespace" "config-syncer" {
  metadata {
    name = "config-syncer"
  }
}

/*
  Deploys config-syncer.

  Helm Chart: https://artifacthub.io/packages/helm/appscode/kubed
  Values: https://github.com/kubeops/config-syncer/blob/v0.13.1/charts/kubed/values.yaml
*/
resource "helm_release" "config-syncer" {
  repository       = "https://charts.appscode.com/stable/"
  chart            = "kubed"
  name             = "config-syncer"
  namespace        = kubernetes_namespace.config-syncer.metadata[0].name
  version          = "v0.13.1"
  create_namespace = false

  set {
    name  = "enableAnalytics"
    value = "false"
  }
}
