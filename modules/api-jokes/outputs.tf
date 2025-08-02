output "endpoint_info" {
  description = "API Jokes endpoint information"
  value = {
    name        = "API Jokes"
    url         = "http://${var.ingress_host}${var.ingress_path}/"
    health      = "http://${var.ingress_host}${var.ingress_path}/health"
    description = "Jokes API service handling ${var.ingress_path}/* requests"
  }
}
