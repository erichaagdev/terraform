variable "cluster_name" {
  default = "coruscant"
}

terraform {
  backend "gcs" {
    bucket = "gorlah"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "gorlah"
  region  = "us-central1"
  zone    = "us-central1-c"
}

data "google_client_config" "current" {}

provider "kubernetes" {
  host  = google_container_cluster.cluster.endpoint
  token = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = google_container_cluster.cluster.endpoint
    token = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(
      google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
    )
  }
}
