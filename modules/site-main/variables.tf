variable "namespace" {
  type    = string
  default = "api-one"
}

variable "ingress_host" {
  type    = string
  default = "localhost:30080"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}
