terraform {
  required_providers {
    google = {
      source = "hashicorp/google-beta"
    }
  }
}

data "google_client_config" "default" {}

locals {
  name = replace(var.domain, ".", "-")
}

resource "google_dns_managed_zone" "dns-zone" {
  name     = local.name
  dns_name = "${var.domain}."

  provisioner "local-exec" {
    command = "gcloud domains registrations configure dns ${var.domain} --cloud-dns-zone=${self.name}"
  }
}

resource "google_dns_record_set" "root-dns" {
  name         = google_dns_managed_zone.dns-zone.dns_name
  managed_zone = google_dns_managed_zone.dns-zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [var.cluster_ip]
}

resource "google_dns_record_set" "wildcard-dns" {
  name         = "*.${google_dns_managed_zone.dns-zone.dns_name}"
  managed_zone = google_dns_managed_zone.dns-zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [var.cluster_ip]
}

resource "google_dns_record_set" "email-dns" {
  name         = google_dns_managed_zone.dns-zone.dns_name
  managed_zone = google_dns_managed_zone.dns-zone.name
  type         = "MX"
  ttl          = 3600

  rrdatas = [
    "5 gmr-smtp-in.l.google.com.",
    "10 alt1.gmr-smtp-in.l.google.com.",
    "20 alt2.gmr-smtp-in.l.google.com.",
    "30 alt3.gmr-smtp-in.l.google.com.",
    "40 alt4.gmr-smtp-in.l.google.com.",
  ]
}
