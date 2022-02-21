terraform {
  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = "4.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }

    /*
      Needed until this issue is resolved:
      https://github.com/hashicorp/terraform-provider-kubernetes/issues/1380
     */
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.1"
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
