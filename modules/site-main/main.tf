resource "kubernetes_namespace" "site_main" {
  metadata {
    name = var.namespace
  }
}

# Create HTML content for the main site
resource "kubernetes_config_map" "site_main" {
  depends_on = [kubernetes_namespace.site_main]
  
  metadata {
    name      = "site-html"
    namespace = var.namespace
  }

  data = {
    "index.html" = templatefile("${path.module}/assets/html/index.html", {
      ingress_host = var.ingress_host
    })
    "health.json" = file("${path.module}/assets/html/health.json")
  }
}

# Create nginx configuration for UTF-8 support
resource "kubernetes_config_map" "nginx_config" {
  depends_on = [kubernetes_namespace.site_main]
  
  metadata {
    name      = "nginx-config"
    namespace = var.namespace
  }

  data = {
    "default.conf" = file("${path.module}/assets/conf.d/default.conf")
  }
}

resource "kubernetes_deployment" "site_main" {
  depends_on = [kubernetes_namespace.site_main]
  
  metadata {
    name      = "${var.namespace}-deployment"
    namespace = var.namespace
    labels = {
      app         = "${var.namespace}"
      component   = "web"
      tier        = "frontend"
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
          component   = "web"
          tier        = "frontend"
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
            name       = "html-content"
            mount_path = "/usr/share/nginx/html"
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/conf.d"
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
          name = "html-content"
          config_map {
            name = kubernetes_config_map.site_main.metadata[0].name
          }
        }

        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "site_main" {
  depends_on = [kubernetes_namespace.site_main]
  
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

resource "kubernetes_ingress_v1" "site_main" {
  depends_on = [kubernetes_namespace.site_main]
  
  metadata {
    name      = "${var.namespace}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"          = "nginx"
      "nginx.ingress.kubernetes.io/priority" = "10"
    }
  }

  spec {
    rule {
      host = var.ingress_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
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
