variable "http_port" {
  description = "NodePort for HTTP traffic"
  type        = string
  default     = "30080"
}

variable "https_port" {
  description = "NodePort for HTTPS traffic"
  type        = string
  default     = "30443"
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt certificate registration"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for ingress controller"
  type        = string
  default     = "ingress-nginx"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}
