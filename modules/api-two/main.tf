resource "kubernetes_namespace" "api_two" {
  count = var.create_namespace ? 1 : 0
  
  metadata {
    name = var.namespace
  }
}

# Create nginx configuration for JSON API responses
resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "api-two-nginx-config"
    namespace = var.namespace
  }

  data = {
    "default.conf" = file("${path.module}/assets/conf.d/default.conf")
  }
}

# Create JSON content for API responses
resource "kubernetes_config_map" "json_content" {
  metadata {
    name      = "api-two-json-content"
    namespace = var.namespace
  }

  data = {
    "index.json"  = file("${path.module}/assets/html/index.json")
    "health.json" = file("${path.module}/assets/html/health.json")
    "404.json"    = file("${path.module}/assets/html/404.json")
  }
}

resource "kubernetes_deployment" "api_two" {
  metadata {
    name      = "api-two-deployment"
    namespace = var.namespace
    labels = {
      app         = "api-two"
      component   = "api"
      tier        = "backend"
      environment = "development"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "api-two"
      }
    }
    template {
      metadata {
        labels = {
          app         = "api-two"
          component   = "api"
          tier        = "backend"
          environment = "development"
        }
      }
      spec {
        container {
          image = "nginx:1.29.0-alpine-slim"
          name  = "api-two"

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

resource "kubernetes_service" "api_two" {
  metadata {
    name      = "api-two-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "api-two"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "api_two" {
  metadata {
    name      = "api-two-ingress"
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
              name = "api-two-service"
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
resource "kubernetes_horizontal_pod_autoscaler_v2" "api_two_hpa" {
  depends_on = [kubernetes_deployment.api_two]
  
  metadata {
    name      = "api-two-hpa"
    namespace = var.namespace
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.api_two.metadata[0].name
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
