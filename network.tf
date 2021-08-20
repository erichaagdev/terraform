resource "google_compute_network" "vpc" {
  name                    = "${var.namespace}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.namespace}-subnet"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_firewall" "firewall" {
  name        = "${var.namespace}-firewall"
  network     = google_compute_network.vpc.name
  target_tags = ["${var.namespace}-node"]

  allow {
    protocol = "tcp"
    ports    = [80, 443]
  }
}

resource "google_compute_address" "static-ip" {
  name = "${var.namespace}-static-ip"
}

resource "null_resource" "assign-ip" {
  triggers = {
    static_ip = google_compute_address.static-ip.address
  }
  provisioner "local-exec" {
    command = "/bin/sh assign-ip.sh ${google_compute_address.static-ip.address}"
  }
}