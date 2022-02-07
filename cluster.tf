resource "google_service_account" "service-account" {
  account_id = "${local.cluster_name}-service-account"
}

resource "google_container_cluster" "cluster" {
  name                     = "${local.cluster_name}-cluster"
  initial_node_count       = 1
  logging_service          = "none"
  monitoring_service       = "none"
  remove_default_node_pool = true
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name

  resource_labels = {
    cluster = "${local.cluster_name}-cluster"
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }

    horizontal_pod_autoscaling {
      disabled = true
    }
  }

  //noinspection MissingProperty
  workload_identity_config {
    workload_pool = "${data.google_client_config.default.project}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary-node-pool" {
  name       = "${local.cluster_name}-primary-node-pool"
  cluster    = google_container_cluster.cluster.name
  node_count = 1

  node_config {
    machine_type    = "e2-medium"
    service_account = google_service_account.service-account.email
    disk_size_gb    = 50

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    tags = [
      "${local.cluster_name}-node"
    ]
  }
}
