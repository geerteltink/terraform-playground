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
