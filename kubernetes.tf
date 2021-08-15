provider "kubernetes" {
  host = google_container_cluster.cluster.endpoint

  client_certificate     = google_container_cluster.cluster.master_auth.0.client_certificate
  client_key             = google_container_cluster.cluster.master_auth.0.client_key
  cluster_ca_certificate = google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
}

resource "kubernetes_namespace" "example-namespace" {
  metadata {
    name = "example"
  }
}
