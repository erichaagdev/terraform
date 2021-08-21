resource "google_compute_network" "vpc" {
  name                    = "${var.cluster-name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster-name}-subnet"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_firewall" "firewall" {
  name        = "${var.cluster-name}-firewall"
  network     = google_compute_network.vpc.name
  target_tags = ["${var.cluster-name}-node"]

  allow {
    protocol = "tcp"
    ports    = [80, 443]
  }
}

resource "google_compute_address" "static-ip" {
  name = "${var.cluster-name}-static-ip"
}

resource "null_resource" "assign-external-ip" {
  triggers = {
    primary_node_pool = google_container_node_pool.primary-node-pool.id
    static_ip = google_compute_address.static-ip.address
  }
  provisioner "local-exec" {
    command = "/bin/sh assign-external-ip.sh ${var.cluster-name} ${google_compute_address.static-ip.address}"
  }
}

resource "null_resource" "update-namecheap-ip" {
  triggers = {
    static_ip = google_compute_address.static-ip.address
  }
  provisioner "local-exec" {
    command = "/bin/sh update-namecheap-ip.sh ${google_compute_address.static-ip.address}"
  }
}
