resource "google_project_iam_custom_role" "node-pool-ip-controller" {
  role_id = "nodePoolIpControllerRole"
  title   = "Node Pool IP Controller"

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

resource "google_service_account" "node-pool-ip-controller" {
  account_id = "node-pool-ip-controller"
}

resource "google_service_account_key" "node-pool-ip-controller" {
  service_account_id = google_service_account.node-pool-ip-controller.name
}

resource "google_project_iam_binding" "node-pool-ip-controller" {
  project = google_project_iam_custom_role.node-pool-ip-controller.project
  role = google_project_iam_custom_role.node-pool-ip-controller.name

  members = [
    "serviceAccount:${google_service_account.node-pool-ip-controller.email}",
  ]
}

resource "kubernetes_namespace" node-pool-ip-controller {
  metadata {
    name = "node-pool-ip-controller"
  }
}

resource "kubernetes_secret" "node-pool-ip-controller" {
  metadata {
    name      = "node-pool-ip-controller-service-account-credentials"
    namespace = kubernetes_namespace.node-pool-ip-controller.id
  }

  data = {
    "key.json" = base64decode(google_service_account_key.node-pool-ip-controller.private_key)
  }
}
