# Create shared namespace for all services (only if not using default)
resource "kubernetes_namespace" "shared" {
  count = var.shared_namespace != "default" ? 1 : 0
  
  metadata {
    name = var.shared_namespace
    labels = {
      "app.kubernetes.io/name" = "dev-environment"
      "app.kubernetes.io/component" = "shared-namespace"
    }
  }
}

module "ingress_controller" {
  source = "./modules/ingress-controller"

  http_port         = var.http_port
  https_port        = var.https_port
  letsencrypt_email = var.letsencrypt_email
  namespace         = var.shared_namespace
  create_namespace  = false
  
  depends_on = [kubernetes_namespace.shared]
}

module "metrics_server" {
  source = "./modules/metrics-server"
}

module "api_one" {
  source = "./modules/api-one"

  ingress_host     = var.ingress_host
  ingress_path     = "/api/one"
  namespace        = var.shared_namespace
  create_namespace = false
  
  depends_on = [kubernetes_namespace.shared, module.metrics_server]
}

module "api_two" {
  source = "./modules/api-two"

  ingress_host     = var.ingress_host
  ingress_path     = "/api/two"
  namespace        = var.shared_namespace
  create_namespace = false
  
  depends_on = [kubernetes_namespace.shared, module.metrics_server]
}

module "site_main" {
  source = "./modules/site-main"

  ingress_host     = var.ingress_host
  namespace        = var.shared_namespace
  create_namespace = false
  
  depends_on = [kubernetes_namespace.shared, module.metrics_server]
}
