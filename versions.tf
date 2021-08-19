terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.79.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }
  }

  required_version = ">= 1.0.0"
}
