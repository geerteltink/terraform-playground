variable "namespace" {
  type    = string
  default = "api-one"
}

variable "ingress_host" {
  type    = string
  default = "localhost:30080"
}

variable "ingress_path" {
  type    = string
  default = "/api/one"
}
