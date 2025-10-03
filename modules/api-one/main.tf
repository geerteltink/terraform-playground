resource "kubernetes_namespace" "api_one" {
  metadata {
    name = var.namespace
  }
}

# Create nginx configuration for JSON API responses
resource "kubernetes_config_map" "nginx_config" {
  depends_on = [kubernetes_namespace.api_one]
  
  metadata {
    name      = "nginx-config"
    namespace = var.namespace
  }

  data = {
    "default.conf" = file("${path.module}/assets/conf.d/default.conf")
  }
}

# Create JSON content for API responses
resource "kubernetes_config_map" "json_content" {
  depends_on = [kubernetes_namespace.api_one]
  
  metadata {
    name      = "json-content"
    namespace = var.namespace
  }

  data = {
    "index.json"  = file("${path.module}/assets/html/index.json")
    "health.json" = file("${path.module}/assets/html/health.json")
    "404.json"    = file("${path.module}/assets/html/404.json")
  }
}

resource "kubernetes_deployment" "api_one" {
  depends_on = [kubernetes_namespace.api_one]
  
  metadata {
    name      = "${var.namespace}-deployment"
    namespace = var.namespace
    labels = {
      app         = "${var.namespace}"
      component   = "api"
      tier        = "backend"
      environment = "development"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "${var.namespace}"
      }
    }
    template {
      metadata {
        labels = {
          app         = "${var.namespace}"
          component   = "api"
          tier        = "backend"
          environment = "development"
        }
      }
      spec {
        container {
          image = "nginx:1.29.0-alpine-slim"
          name  = var.namespace

          port {
            container_port = 80
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/conf.d"
          }

          volume_mount {
            name       = "json-content"
            mount_path = "/usr/share/nginx/html"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }

        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
          }
        }

        volume {
          name = "json-content"
          config_map {
            name = kubernetes_config_map.json_content.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api_one" {
  depends_on = [kubernetes_namespace.api_one]
  
  metadata {
    name      = "${var.namespace}-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "${var.namespace}"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "api_one" {
  depends_on = [kubernetes_namespace.api_one]
  
  metadata {
    name      = "${var.namespace}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
    }
  }

  spec {
    rule {
      host = var.ingress_host
      http {
        path {
          path      = "${var.ingress_path}(/|$)(.*)"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "${var.namespace}-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
