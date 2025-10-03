# Health check endpoints
output "health_check_urls" {
  description = "Health check URLs for monitoring"
  value = {
    site_main = module.site_main.endpoint_info.health
    api_one   = module.api_one.endpoint_info.health
    api_two   = module.api_two.endpoint_info.health
  }
}

# API endpoints
output "api_endpoints" {
  description = "All API endpoints available in the cluster"
  value = {
    site_main = module.site_main.endpoint_info
    api_one   = module.api_one.endpoint_info
    api_two   = module.api_two.endpoint_info
  }
}
