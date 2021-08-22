data "google_storage_bucket_object_content" "erichaag-io-public-key" {
  name   = "certificates/erichaag.io/fullchain.pem"
  bucket = "gorlah"
}

data "google_storage_bucket_object_content" "erichaag-io-private-key" {
  name   = "certificates/erichaag.io/privkey.pem"
  bucket = "gorlah"
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
