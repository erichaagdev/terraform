variable "email" {
  description = "Email address to use during ACME account registration."
  type        = string
}

variable "install_namespace" {
  description = "The namespace where issuers will be installed."
  type        = string
}
