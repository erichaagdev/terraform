terraform {
  backend "gcs" {
    bucket = "gorlah"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = "4.9.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.1"
    }
    kubectl-fork = {
      // needed until https://github.com/gavinbunney/terraform-provider-kubectl/issues/109 is merged and released
      source  = "alekc-forks/kubectl"
      version = "1.13.1-1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
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
  host                   = module.coruscant.cluster_endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = module.coruscant.cluster_certificate
}

provider "helm" {
  kubernetes {
    host                   = module.coruscant.cluster_endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = module.coruscant.cluster_certificate
  }
}

provider "kubectl" {
  host                   = module.coruscant.cluster_endpoint
  token                  = data.google_client_config.default.access_token
  load_config_file       = false
  cluster_ca_certificate = module.coruscant.cluster_certificate
}
