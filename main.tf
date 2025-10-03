module "ingress_controller" {
  source = "./modules/ingress-controller"

  http_port         = var.http_port
  https_port        = var.https_port
  letsencrypt_email = var.letsencrypt_email
}

module "api_one" {
  source = "./modules/api-one"

  ingress_host = var.ingress_host
  ingress_path = "/api/one"
  namespace    = "api-one"
}

module "api_two" {
  source = "./modules/api-two"

  ingress_host = var.ingress_host
  ingress_path = "/api/two"
  namespace    = "api-two"
}

module "site_main" {
  source = "./modules/site-main"

  ingress_host = var.ingress_host
  namespace    = "site-main"
}
