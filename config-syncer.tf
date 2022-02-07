/*
  Deploys config-syncer.

  Helm Chart: https://artifacthub.io/packages/helm/appscode/kubed
  Values: https://github.com/kubeops/config-syncer/blob/v0.13.1/charts/kubed/values.yaml
*/
resource "helm_release" "config-syncer" {
  repository       = "https://charts.appscode.com/stable/"
  chart            = "kubed"
  name             = "config-syncer"
  namespace        = "config-syncer"
  version          = "v0.13.1"
  create_namespace = true

  depends_on = [google_container_node_pool.primary-node-pool]

  set {
    name  = "enableAnalytics"
    value = "false"
  }
}
