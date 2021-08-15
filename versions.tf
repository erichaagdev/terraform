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
  }

  required_version = ">= 1.0.0"
}
