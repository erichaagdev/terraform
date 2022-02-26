module "coruscant" {
  source       = "./modules/cluster"
  cluster_name = local.cluster_name
}

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

module "certificate_issuers" {
  source     = "./modules/certificates/issuers"
  depends_on = [module.cert-manager]

  email             = local.email
  install_namespace = local.certificate_namespace
}
