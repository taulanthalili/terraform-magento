# terraform-magento
Argocd magento application

How to use it:

```
module "magento_app" {
  source          = "git::https://github.com/taulanthalili/terraform-magento.git?ref=main"
  namespace       = var.project_name
  environment     = var.environment
  magneto_domain  = var.project_domain
  argocd_project  = "default"
  ingressClassName = "nginx"
  magento_dev     = var.magento_dev
  mariadb_password = var.mariadb_password
  mariadb_root_password = var.mariadb_root_password
  magento_version = var.magento_version
  depends_on      = [module.argocd]
}

```
