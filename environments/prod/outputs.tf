output "endpoints" {
  description = "URLs for each running instance."
  value       = module.web.endpoints
}

output "network_name" {
  value = module.web.network_name
}
