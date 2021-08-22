resource "google_service_account" "service-account" {
  account_id = "${var.cluster_name}-service-account"
}

resource "google_container_cluster" "cluster" {
  name                     = "${var.cluster_name}-cluster"
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
  name       = "${var.cluster_name}-primary-node-pool"
  cluster    = google_container_cluster.cluster.name
  node_count = 1

  node_config {
    machine_type    = "e2-medium"
    service_account = google_service_account.service-account.email
    disk_size_gb    = 20

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    metadata = {
      disable-legacy-endpoints = true
    }

    tags = [
      "${var.cluster_name}-node"
    ]
  }
}
