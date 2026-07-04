variable "service_name" {
  type        = string
  description = "Logical name of the web service. Used to name Docker objects."

  validation {
    condition     = length(var.service_name) > 0 && can(regex("^[a-z0-9-]+$", var.service_name))
    error_message = "service_name must be non-empty and only contain lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "image" {
  type        = string
  description = "Container image to run."
  default     = "nginx:1.27-alpine"
}

# Complex type: a map of objects. Each key is an instance name, the value
# carries that instance's host port. Drives a for_each over containers.
variable "instances" {
  type = map(object({
    host_port = number
  }))
  description = "Map of instance name => settings. One container is created per entry."

  validation {
    condition = alltrue([
      for inst in var.instances : inst.host_port >= 1024 && inst.host_port <= 65535
    ])
    error_message = "Every host_port must be between 1024 and 65535."
  }
}

variable "extra_labels" {
  type        = map(string)
  description = "Additional labels applied to every container."
  default     = {}
}
