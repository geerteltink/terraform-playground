variable "namespace" {
  type    = string
  default = "api-two"
}

variable "ingress_host" {
  description = "Host for ingress endpoints"
  type        = string
  default     = "localhost:30080"
}

variable "ingress_path" {
  type    = string
  default = "/api/two"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}
