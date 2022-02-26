terraform {
  required_providers {
    google = {
      source = "hashicorp/google-beta"
    }
  }
}

data "google_client_config" "default" {}

resource "google_compute_network" "cluster" {
  name                    = var.cluster_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "cluster" {
  name          = var.cluster_name
  network       = google_compute_network.cluster.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_firewall" "cluster" {
  name        = var.cluster_name
  network     = google_compute_network.cluster.name
  target_tags = [var.cluster_name]

  allow {
    protocol = "tcp"
    ports    = [80, 443]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_service_account" "cluster" {
  account_id = var.cluster_name
}

resource "google_container_cluster" "cluster" {
  name                     = var.cluster_name
  initial_node_count       = 1
  logging_service          = "none"
  monitoring_service       = "none"
  remove_default_node_pool = true
  network                  = google_compute_network.cluster.name
  subnetwork               = google_compute_subnetwork.cluster.name

  resource_labels = {
    cluster = var.cluster_name
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }

    horizontal_pod_autoscaling {
      disabled = true
    }
  }

  workload_identity_config {
    workload_pool = "${data.google_client_config.default.project}.svc.id.goog"
  }
}

resource "google_container_node_pool" "cluster" {
  name       = var.cluster_name
  cluster    = google_container_cluster.cluster.name
  node_count = 1

  node_config {
    machine_type    = "e2-medium"
    service_account = google_service_account.cluster.email
    disk_size_gb    = 50

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    tags = [
      var.cluster_name
    ]
  }
}

resource "google_compute_address" "cluster" {
  name = var.cluster_name

  depends_on = [google_container_node_pool.cluster]
}
