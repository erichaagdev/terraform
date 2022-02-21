output "cluster_endpoint" {
  description = "The endpoint used to access the cluster."
  value       = "https://${google_container_cluster.cluster.endpoint}"
}

output "cluster_certificate" {
  description = "The cluster certificate."
  value       = base64decode(google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
}

output "cluster_ip" {
  description = "The public IP address of the cluster."
  value       = google_compute_address.cluster.address
}
