variable "namespace" {
  default = "coruscant"
}

terraform {
  backend "gcs" {
    bucket = "gorlah"
    prefix = "terraform/state"
  }
}
