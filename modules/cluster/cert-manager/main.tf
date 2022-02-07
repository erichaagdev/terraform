locals {
  serviceAccountName = "certificate-issuer"
}

/*
  Configures certificate-issuer Google service account.

  https://cert-manager.io/docs/configuration/acme/dns01/google/#set-up-a-service-account
*/

resource "google_service_account" "certificate-issuer" {
  account_id = local.serviceAccountName
  project    = var.project
}

resource "google_project_iam_custom_role" "certificate-issuer" {
  project = var.project
  role_id = "certificateIssuer"
  title   = "Certificate Issuer"

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

resource "google_project_iam_binding" "certificate-issuer" {
  project = var.project
  role    = google_project_iam_custom_role.certificate-issuer.name

  members = [
    "serviceAccount:${google_service_account.certificate-issuer.email}",
  ]
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
  namespace        = "cert-manager"
  version          = "1.7.1"
  create_namespace = true

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
    value = google_service_account.certificate-issuer.email
  }

  set {
    name  = "extraArgs"
    value = "{--issuer-ambient-credentials=true}"
  }
}


/*
  Adds certificate-issuer Kubernetes service account as workload identity user.
*/
resource "google_project_iam_member" "certificate-issuer" {
  project = var.project
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${var.project}.svc.id.goog[${helm_release.cert-manager.namespace}/${local.serviceAccountName}]"
}
