module "erichaag-dev" {
  source = "./modules/applications"

  argocd     = module.argocd.install_namespace
  name       = "erichaag-dev"
  path       = "erichaagdev/erichaag.dev/prod"
  repository = "https://github.com/erichaagdev/deployments"
}
