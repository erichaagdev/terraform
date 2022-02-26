output "staging_issuer" {
  description = "The name of the staging issuer."
  value       = "letsencrypt-staging"
}

output "production_issuer" {
  description = "The name of the production issuer."
  value       = "letsencrypt"
}

output "install_namespace" {
  description = "The name of the namespace to install certificates."
  value       = kubernetes_namespace.certificates.metadata[0].name
}
