resource "google_dns_managed_zone" "erichaag-dev-dns-zone" {
  name     = "erichaag-dev-dns-zone"
  dns_name = "erichaag.dev."
}

resource "google_dns_record_set" "erichaag-dev-root-dns" {
  name         = google_dns_managed_zone.erichaag-dev-dns-zone.dns_name
  managed_zone = google_dns_managed_zone.erichaag-dev-dns-zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_address.ip.address]
}

resource "google_dns_record_set" "erichaag-dev-wildcard-dns" {
  name         = "*.${google_dns_managed_zone.erichaag-dev-dns-zone.dns_name}"
  managed_zone = google_dns_managed_zone.erichaag-dev-dns-zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_address.ip.address]
}

resource "google_dns_record_set" "erichaag-dev-email-dns" {
  name         = google_dns_managed_zone.erichaag-dev-dns-zone.dns_name
  managed_zone = google_dns_managed_zone.erichaag-dev-dns-zone.name
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

locals {
  bucket      = "gorlah-certs"
  private-key = "domains/%s/certificates/privkey.pem"
  public-key  = "domains/%s/certificates/fullchain.pem"
}

data "google_storage_bucket_object_content" "erichaag-dev-public-key" {
  name   = format(local.public-key, "erichaag.dev")
  bucket = local.bucket
}

data "google_storage_bucket_object_content" "erichaag-dev-private-key" {
  name   = format(local.private-key, "erichaag.dev")
  bucket = local.bucket
}

resource "kubernetes_secret" "erichaag-dev-tls-default" {
  type = "kubernetes.io/tls"

  metadata {
    name      = "erichaag-dev-tls-secret"
    namespace = "default"
  }

  data = {
    "tls.crt" = data.google_storage_bucket_object_content.erichaag-dev-public-key.content
    "tls.key" = data.google_storage_bucket_object_content.erichaag-dev-private-key.content
  }
}
