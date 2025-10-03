resource "kubernetes_namespace" "site_main" {
  count = var.create_namespace ? 1 : 0
  
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
    name      = "site-main-nginx-config"
    namespace = var.namespace
  }

  data = {
    "default.conf" = file("${path.module}/assets/conf.d/default.conf")
  }
}

resource "kubernetes_deployment" "site_main" {
  depends_on = [kubernetes_namespace.site_main]
  
  metadata {
    name      = "site-main-deployment"
    namespace = var.namespace
    labels = {
      app         = "site-main"
      component   = "web"
      tier        = "frontend"
      environment = "development"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "site-main"
      }
    }
    template {
      metadata {
        labels = {
          app         = "site-main"
          component   = "web"
          tier        = "frontend"
          environment = "development"
        }
      }
      spec {
        container {
          image = "nginx:1.29.0-alpine-slim"
          name  = "site-main"

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
    name      = "site-main-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "site-main"
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
    name      = "site-main-ingress"
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
              name = "site-main-service"
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

# Horizontal Pod Autoscaler for automatic scaling
resource "kubernetes_horizontal_pod_autoscaler_v2" "site_main_hpa" {
  depends_on = [kubernetes_deployment.site_main]
  
  metadata {
    name      = "site-main-hpa"
    namespace = var.namespace
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.site_main.metadata[0].name
    }

    min_replicas = 1
    max_replicas = 4

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 60
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }

    behavior {
      scale_up {
        stabilization_window_seconds = 15
        select_policy               = "Max"
        policy {
          type          = "Percent"
          value         = 50
          period_seconds = 60
        }
        policy {
          type          = "Pods"
          value         = 5
          period_seconds = 120
        }
      }
      
      scale_down {
        stabilization_window_seconds = 60
        select_policy               = "Min"
        policy {
          type          = "Percent"
          value         = 10
          period_seconds = 120
        }
        policy {
          type          = "Pods"
          value         = 2
          period_seconds = 300
        }
      }
    }
  }
}
