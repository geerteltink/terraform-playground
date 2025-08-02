output "endpoint_info" {
  description = "API Two endpoint information"
  value = {
    name        = "API Two"
    url         = "http://${var.ingress_host}${var.ingress_path}"
    health      = "http://${var.ingress_host}${var.ingress_path}/health"
    description = "Second API service handling ${var.ingress_path}/* requests"
  }
}
