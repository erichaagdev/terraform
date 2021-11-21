locals {
  cluster_name = "coruscant"
}

terraform {
  backend "gcs" {
    bucket = "gorlah"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = "4.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.6.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "google" {
  project = "gorlah"
  region  = "us-central1"
  zone    = "us-central1-c"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host  = "https://${google_container_cluster.cluster.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${google_container_cluster.cluster.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
    )
  }
}
