#locals {
#  mongo-pod-selector = "mongo"
#}
#
#resource "kubernetes_namespace" "mongo-namespace" {
#  metadata {
#    name = "mongo"
#  }
#}
#
#resource "kubernetes_service" "mongo-service" {
#  metadata {
#    name      = "mongo-service"
#    namespace = kubernetes_namespace.mongo-namespace.metadata[0].name
#
#    labels = {
#      app = local.mongo-pod-selector
#    }
#  }
#
#  spec {
#    cluster_ip = "None"
#
#    port {
#      port = 27017
#    }
#
#    selector = {
#      app = local.mongo-pod-selector
#    }
#  }
#}
#
#resource "kubernetes_stateful_set" "mongo-stateful-set" {
#  metadata {
#    name      = "mongo-stateful-set"
#    namespace = kubernetes_namespace.mongo-namespace.metadata[0].name
#
#    labels = {
#      app = local.mongo-pod-selector
#    }
#  }
#
#  spec {
#    service_name = kubernetes_service.mongo-service.metadata[0].name
#    replicas     = 1
#
#    selector {
#      match_labels = {
#        app = local.mongo-pod-selector
#      }
#    }
#
#    template {
#      metadata {
#        labels = {
#          app = local.mongo-pod-selector
#        }
#      }
#
#      spec {
#        termination_grace_period_seconds = 10
#
#        container {
#          name  = "mongo"
#          image = "mongo:5.0.1"
#
#          port {
#            container_port = 27017
#          }
#
#          volume_mount {
#            name       = "mongo-volume-claim"
#            mount_path = "/data/db"
#          }
#        }
#      }
#    }
#
#    volume_claim_template {
#      metadata {
#        name = "mongo-volume-claim"
#      }
#
#      spec {
#        access_modes       = ["ReadWriteOnce"]
#        storage_class_name = "standard"
#
#        resources {
#          requests = {
#            storage = "2Gi"
#          }
#        }
#      }
#    }
#  }
#}
