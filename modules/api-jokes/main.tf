resource "kubernetes_namespace" "api_jokes" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service" "api_jokes" {
  metadata {
    name      = "${var.namespace}-service"
    namespace = var.namespace
  }

  spec {
    type          = "ExternalName"
    external_name = "official-joke-api.appspot.com"
    port {
      port = 443
    }
  }
}

resource "kubernetes_ingress_v1" "api_jokes" {
  metadata {
    name      = "${var.namespace}-ingress"
    namespace = var.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/upstream-vhost"   = "official-joke-api.appspot.com"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      "nginx.ingress.kubernetes.io/rewrite-target"   = "/jokes/$1"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "${var.ingress_path}/(.*)"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "${var.namespace}-service"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}
