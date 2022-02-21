terraform {
  backend "gcs" {
    bucket = "gorlah"
    prefix = "terraform/state"
  }
}

module "coruscant" {
  source       = "./modules/cluster"
  cluster_name = "coruscant"
}

module "certificates" {
  source     = "./modules/certificates"
  depends_on = [module.cert-manager]
}

/*
  Cluster applications
*/
module "cert-manager" {
  source     = "./modules/apps/cert-manager"
  depends_on = [module.coruscant]
}

module "config-syncer" {
  source     = "./modules/apps/config-syncer"
  depends_on = [module.coruscant]
}

module "ingress-nginx" {
  source     = "./modules/apps/ingress-nginx"
  depends_on = [module.coruscant]
}

module "erichaag-dev" {
  source     = "./modules/apps/erichaag.dev"
  depends_on = [module.coruscant]
  cluster_ip = module.coruscant.cluster_ip
}
