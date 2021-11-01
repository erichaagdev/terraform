locals {
  bucket      = "gorlah-certs"
  private-key = "domains/%s/certificates/privkey.pem"
  public-key  = "domains/%s/certificates/fullchain.pem"
}

data "google_storage_bucket_object_content" "erichaag-io-public-key" {
  name   = format(local.public-key, "erichaag.io")
  bucket = local.bucket
}

data "google_storage_bucket_object_content" "erichaag-io-private-key" {
  name   = format(local.private-key, "erichaag.io")
  bucket = local.bucket
}

resource "kubernetes_secret" "erichaag-io-tls-default" {
  type = "kubernetes.io/tls"

  metadata {
    name      = "erichaag-io-tls-secret"
    namespace = "default"
  }

  data = {
    "tls.crt" = data.google_storage_bucket_object_content.erichaag-io-public-key.content
    "tls.key" = data.google_storage_bucket_object_content.erichaag-io-private-key.content
  }
}

data "google_storage_bucket_object_content" "gorlah-com-public-key" {
  name   = format(local.public-key, "gorlah.com")
  bucket = local.bucket
}

data "google_storage_bucket_object_content" "gorlah-com-private-key" {
  name   = format(local.private-key, "gorlah.com")
  bucket = local.bucket
}

resource "kubernetes_secret" "gorlah-com-tls-default" {
  type = "kubernetes.io/tls"

  metadata {
    name      = "gorlah-com-tls-secret"
    namespace = "default"
  }

  data = {
    "tls.crt" = data.google_storage_bucket_object_content.gorlah-com-public-key.content
    "tls.key" = data.google_storage_bucket_object_content.gorlah-com-private-key.content
  }
}

data "google_storage_bucket_object_content" "mamamech-rocks-public-key" {
  name   = format(local.public-key, "mamamech.rocks")
  bucket = local.bucket
}

data "google_storage_bucket_object_content" "mamamech-rocks-private-key" {
  name   = format(local.private-key, "mamamech.rocks")
  bucket = local.bucket
}

resource "kubernetes_secret" "mamamech-rocks-tls-default" {
  type = "kubernetes.io/tls"

  metadata {
    name      = "mamamech-rocks-tls-secret"
    namespace = kubernetes_namespace.mamamech-namespace.metadata[0].name
  }

  data = {
    "tls.crt" = data.google_storage_bucket_object_content.mamamech-rocks-public-key.content
    "tls.key" = data.google_storage_bucket_object_content.mamamech-rocks-private-key.content
  }
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
