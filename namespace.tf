resource "kubernetes_namespace" "mamamech-namespace" {
  metadata {
    name = "mamamech"
  }
}
