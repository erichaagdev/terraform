terraform {
  required_providers {
    google = {
      source = "hashicorp/google-beta"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

locals {
  serviceAccountName = "cert-manager"
}

data "google_client_config" "default" {}

/*
  Configures cert-manager Google service account.

  https://cert-manager.io/docs/configuration/acme/dns01/google/#set-up-a-service-account
*/
resource "google_service_account" "cert-manager" {
  account_id = local.serviceAccountName
  project    = data.google_client_config.default.project
}

resource "google_project_iam_custom_role" "cert-manager" {
  project = data.google_client_config.default.project
  role_id = "certManager"
  title   = "Cert Manager"

  permissions = [
    "dns.changes.create",
    "dns.changes.get",
    "dns.changes.list",
    "dns.managedZones.list",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.get",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
  ]
}

resource "google_project_iam_binding" "cert-manager" {
  project = data.google_client_config.default.project
  role    = google_project_iam_custom_role.cert-manager.name

  members = [
    "serviceAccount:${google_service_account.cert-manager.email}",
  ]
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

/*
  Deploys cert-manager.

  Helm Chart: https://artifacthub.io/packages/helm/cert-manager/cert-manager
  Values: https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml
*/
resource "helm_release" "cert-manager" {
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  name             = "cert-manager"
  namespace        = kubernetes_namespace.cert-manager.metadata[0].name
  version          = "1.7.1"
  create_namespace = false

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "serviceAccount.name"
    value = local.serviceAccountName
  }

  set {
    name  = "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
    value = google_service_account.cert-manager.email
  }

  set {
    name  = "extraArgs"
    value = "{--issuer-ambient-credentials=true}"
  }
}

/*
  Adds cert-manager Kubernetes service account as workload identity user.
*/
resource "google_project_iam_member" "cert-manager" {
  project = data.google_client_config.default.project
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${data.google_client_config.default.project}.svc.id.goog[${helm_release.cert-manager.namespace}/${local.serviceAccountName}]"
}
