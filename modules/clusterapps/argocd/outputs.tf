output "install_namespace" {
  description = "The namespace where Argo CD was installed."
  value       = kubernetes_namespace.argocd.metadata[0].name
}
