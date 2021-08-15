provider "google" {
  project = "gorlah"
  region  = "us-central1"
  zone    = "us-central1-c"
}

data "google_client_config" "provider" {

}

resource "google_service_account" "service-account" {
  account_id = "${var.namespace}-service-account"
}

resource "google_container_cluster" "cluster" {
  name                     = "${var.namespace}-cluster"
  initial_node_count       = 1
  logging_service          = "none"
  monitoring_service       = "none"
  remove_default_node_pool = true
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name

  addons_config {
    http_load_balancing {
      disabled = true
    }

    horizontal_pod_autoscaling {
      disabled = true
    }
  }
}

resource "google_container_node_pool" "primary-node-pool" {
  name       = "${var.namespace}-primary-node-pool"
  cluster    = google_container_cluster.cluster.name
  node_count = 1

  node_config {
    machine_type    = "e2-medium"
    service_account = google_service_account.service-account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    metadata = {
      disable-legacy-endpoints = true
    }
  }
}

resource "google_compute_network" "vpc" {
  name                    = "${var.namespace}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.namespace}-subnet"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}
