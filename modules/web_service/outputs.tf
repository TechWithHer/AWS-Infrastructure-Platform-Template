output "network_name" {
  description = "Name of the Docker network created for this service."
  value       = docker_network.this.name
}

output "endpoints" {
  description = "Map of instance name => reachable URL."
  value = {
    for name, settings in var.instances :
    name => "http://localhost:${settings.host_port}"
  }
}

output "container_names" {
  description = "Names of all containers created."
  value       = [for c in docker_container.this : c.name]
}
