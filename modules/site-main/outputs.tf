output "endpoint_info" {
  description = "Main Site information"
  value = {
    name        = "Main Site"
    url         = "http://${var.ingress_host}/"
    health      = "http://${var.ingress_host}/health"
    description = "Main Site /* requests"
  }
}
