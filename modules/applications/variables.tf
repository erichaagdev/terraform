variable "argocd" {
  description = "The namespace where Argo CD is installed."
  type        = string
}

variable "name" {
  description = "The name of the application."
  type        = string
}

variable "namespace" {
  description = "The namespace where the application will be installed."
  default     = null
  type        = string
}

variable "repository" {
  description = "The repository to obtain the deployment manifests from."
  type        = string
}

variable "path" {
  description = "The path within the repository."
  type        = string
}
