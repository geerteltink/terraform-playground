variable "ingress_host" {
  description = "Base host for all API endpoints"
  type        = string
  default     = "dev.elt.ink"
}

variable "http_port" {
  description = "HTTP port for ingress controller"
  type        = string
  default     = "30080"
}

variable "https_port" {
  description = "HTTPS port for ingress controller"
  type        = string
  default     = "30443"
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt certificates"
  type        = string
  default     = "letsencrypt.qo1ww@m.elt.ink"
}
