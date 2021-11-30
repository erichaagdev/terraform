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
    namespace = kubernetes_namespace.erichaag-dev.id
  }

  data = {
    "tls.crt" = data.google_storage_bucket_object_content.erichaag-dev-public-key.content
    "tls.key" = data.google_storage_bucket_object_content.erichaag-dev-private-key.content
  }
}

resource "kubernetes_namespace" "erichaag-dev" {
  metadata {
    name = "erichaag-dev"
  }
}

resource "kubernetes_deployment" "erichaag-dev" {
  metadata {
    name      = "erichaag-dev"
    namespace = kubernetes_namespace.erichaag-dev.id

    labels = {
      "app" = "erichaag-dev"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "erichaag-dev"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "erichaag-dev"
        }
      }

      spec {
        container {
          name  = "erichaag-dev"
          image = "ghcr.io/erichaagdev/erichaag.dev:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "erichaag-dev" {
  metadata {
    name      = "erichaag-dev"
    namespace = kubernetes_namespace.erichaag-dev.id

    labels = {
      "app" = "erichaag-dev"
    }
  }

  spec {
    selector = {
      "app" = "erichaag-dev"
    }

    port {
      port        = 80
      protocol    = "TCP"
      target_port = 80
    }
  }
}

resource "kubernetes_ingress" "erichaag-dev" {
  metadata {
    name      = "erichaag-dev"
    namespace = kubernetes_namespace.erichaag-dev.id

    labels = {
      "app" = "erichaag-dev"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "erichaag.dev"
      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.erichaag-dev.metadata[0].name
            service_port = 80
          }
        }
      }
    }

    tls {
      hosts       = ["erichaag.dev"]
      secret_name = kubernetes_secret.erichaag-dev-tls-default.metadata[0].name
    }
  }
}