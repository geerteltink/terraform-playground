output "endpoint_info" {
  description = "API One endpoint information"
  value = {
    name        = "API One"
    url         = "http://${var.ingress_host}${var.ingress_path}"
    health      = "http://${var.ingress_host}${var.ingress_path}/health"
    description = "First API service handling ${var.ingress_path}/* requests"
  }
}
