variable "domain" {
  description = "The domain name."
  type        = string
}

variable "install_namespace" {
  description = "The namespace where certificate will be installed."
  type        = string
}

variable "issuer" {
  description = "The issuer to use when requesting the certificate."
  type        = string
}
