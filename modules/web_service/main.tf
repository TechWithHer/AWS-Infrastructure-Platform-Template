locals {
  # merge() + map manipulation -> a common label set for every container
  common_labels = merge(
    {
      "managed-by"  = "terraform"
      "service"     = var.service_name
      "environment" = var.environment
    },
    var.extra_labels
  )

  # naming convention used across all Docker objects
  name_prefix = "${var.service_name}-${var.environment}"
}

# Pull the image (data-like managed resource; kept locally to speed up re-runs)
resource "docker_image" "this" {
  name         = var.image
  keep_locally = true
}

# One isolated network per service+environment
resource "docker_network" "this" {
  name = "${local.name_prefix}-net"
}

# for_each over the instances map: stable addressing by name, not index
resource "docker_container" "this" {
  for_each = var.instances

  name  = "${local.name_prefix}-${each.key}"
  image = docker_image.this.image_id

  # implicit dependency on the network resource via reference
  networks_advanced {
    name = docker_network.this.name
  }

  ports {
    internal = 80
    external = each.value.host_port
  }

  # dynamic block: turn the labels map into repeated label blocks
  dynamic "labels" {
    for_each = local.common_labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  # render a templated landing page and upload it into the container
  upload {
    file    = "/usr/share/nginx/html/index.html"
    content = templatefile("${path.module}/templates/index.html.tpl", {
      service     = var.service_name
      environment = upper(var.environment)
      instance    = each.key
      host_port   = each.value.host_port
    })
  }

  lifecycle {
    create_before_destroy = true

    # postcondition (004): assert the container actually exposes the expected port
    postcondition {
      condition     = length(self.ports) == 1
      error_message = "Container ${each.key} must expose exactly one port."
    }
  }

  restart = var.environment == "prod" ? "always" : "no"
}
