terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_namespace" "erichaag-dev" {
  metadata {
    name = "erichaag-dev"
    labels = {
      "erichaag.dev/install-certificate" = ""
    }
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
      secret_name = "erichaag-dev-tls"
    }
  }
}
