module "erichaag-dev" {
  source     = "./modules/apps/erichaag.dev"
  depends_on = [module.coruscant]
}
