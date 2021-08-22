resource "google_compute_network" "vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-subnet"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_firewall" "firewall" {
  name        = "${var.cluster_name}-firewall"
  network     = google_compute_network.vpc.name
  target_tags = ["${var.cluster_name}-node"]

  allow {
    protocol = "tcp"
    ports    = [80, 443]
  }
}

resource "google_compute_address" "static-ip" {
  name = "${var.cluster_name}-static-ip"
}

resource "null_resource" "assign-external-ip" {
  triggers = {
    primary_node_pool = google_container_node_pool.primary-node-pool.id
    static_ip         = google_compute_address.static-ip.address
  }

  provisioner "local-exec" {
    command = "/bin/sh ./scripts/assign-external-ip.sh ${var.cluster_name}-cluster ${data.google_client_config.current.zone} ${google_compute_address.static-ip.address}"
  }
}

variable "erichaag_io_dns_password" {
  sensitive = true
}

resource "null_resource" "erichaag-io-dns" {
  triggers = {
    static_ip = google_compute_address.static-ip.address
  }

  provisioner "local-exec" {
    command = "/bin/sh ./scripts/update-namecheap-ip.sh erichaag.io ${google_compute_address.static-ip.address} ${var.erichaag_io_dns_password}"
  }
}

variable "gorlah_com_dns_password" {
  sensitive = true
}

resource "null_resource" "gorlah-com-dns" {
  triggers = {
    static_ip = google_compute_address.static-ip.address
  }

  provisioner "local-exec" {
    command = "/bin/sh ./scripts/update-namecheap-ip.sh gorlah.com ${google_compute_address.static-ip.address} ${var.gorlah_com_dns_password}"
  }
}
