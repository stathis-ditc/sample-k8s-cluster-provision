module "bootstrap" {
  source = "./modules/bootstrap"
}

module "argocd" {
  source = "./modules/argocd"

  depends_on = [module.bootstrap]
}

module "postgres" {
  source = "./modules/postgres"
}
