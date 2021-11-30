resource "google_cloud_run_service" "node-pool-ip-func" {
  name     = "node-pool-ip-func"
  location = data.google_client_config.default.region

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/gorlah/docker/node-pool-ip-func:latest"
        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = data.google_client_config.default.project
        }
        env {
          name  = "GOOGLE_CLOUD_REGION"
          value = data.google_client_config.default.region
        }
        env {
          name  = "GOOGLE_CLOUD_ZONE"
          value = data.google_client_config.default.zone
        }
      }
    }
  }

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "all"
    }
  }
}

resource "google_project_iam_custom_role" "node-pool-ip" {
  role_id = "nodePoolIpRole"
  title   = "Node Pool IP"

  permissions = [
    "compute.addresses.get",
    "compute.addresses.list",
    "compute.addresses.use",
    "compute.instanceGroups.get",
    "compute.instances.addAccessConfig",
    "compute.instances.deleteAccessConfig",
    "compute.instances.get",
    "compute.instances.list",
    "compute.networks.useExternalIp",
    "compute.projects.get",
    "compute.subnetworks.useExternalIp",
    "container.clusters.get",
    "container.clusters.list",
    "resourcemanager.projects.get",
  ]
}

resource "google_service_account" "node-pool-ip" {
  account_id = "node-pool-ip"
}

resource "google_project_iam_binding" "node-pool-ip-controller" {
  project = data.google_client_config.default.project
  role    = google_project_iam_custom_role.node-pool-ip.name

  members = [
    "serviceAccount:${google_service_account.node-pool-ip.email}",
  ]
}

resource "google_project_iam_member" "node-pool-ip" {
  project = data.google_client_config.default.project
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.node-pool-ip.email}"
}

resource "google_service_account_key" "node-pool-ip" {
  service_account_id = google_service_account.node-pool-ip.name
}

resource "kubernetes_namespace" "node-pool-ip" {
  metadata {
    name = "node-pool-ip"
  }
}

resource "kubernetes_secret" "node-pool-ip" {
  metadata {
    name      = "node-pool-ip-service-account-key"
    namespace = kubernetes_namespace.node-pool-ip.id
  }

  data = {
    "key.json" = base64decode(google_service_account_key.node-pool-ip.private_key)
  }
}
