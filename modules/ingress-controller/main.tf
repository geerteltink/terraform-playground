resource "kubernetes_namespace" "ingress_nginx" {
  count = var.create_namespace ? 1 : 0
  
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = var.namespace

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.service.nodePorts.http"
    value = var.http_port
  }

  set {
    name  = "controller.service.nodePorts.https"
    value = var.https_port
  }
}

# # Install cert-manager for SSL certificates
# resource "helm_release" "cert_manager" {
#   name             = "cert-manager"
#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"
#   namespace        = "cert-manager"
#   create_namespace = true

#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
# }

# # Create Let's Encrypt ClusterIssuer
# resource "kubernetes_manifest" "letsencrypt_issuer" {
#   depends_on = [helm_release.cert_manager]

#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "ClusterIssuer"
#     metadata = {
#       name = "letsencrypt-prod"
#     }
#     spec = {
#       acme = {
#         server = "https://acme-v02.api.letsencrypt.org/directory"
#         email  = var.letsencrypt_email
#         privateKeySecretRef = {
#           name = "letsencrypt-prod"
#         }
#         solvers = [{
#           http01 = {
#             ingress = {
#               class = "nginx"
#             }
#           }
#         }]
#       }
#     }
#   }
# }
