module "dns" {
  for_each = toset(local.domains)

  source     = "./modules/dns"
  depends_on = [module.coruscant]

  cluster_ip = module.coruscant.cluster_ip
  domain     = each.value
}

module "certificate" {
  for_each = module.dns

  source = "./modules/certificates/certificate"

  domain            = each.value.domain
  install_namespace = module.certificate_issuers.install_namespace
  issuer            = module.certificate_issuers.staging_issuer
}
