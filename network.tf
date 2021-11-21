resource "google_compute_network" "vpc" {
  name                    = "${local.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${local.cluster_name}-subnet"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_firewall" "firewall" {
  name        = "${local.cluster_name}-firewall"
  network     = google_compute_network.vpc.name
  target_tags = ["${local.cluster_name}-node"]

  allow {
    protocol = "tcp"
    ports    = [80, 443]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "ip" {
  name = "${local.cluster_name}-ip"
}
