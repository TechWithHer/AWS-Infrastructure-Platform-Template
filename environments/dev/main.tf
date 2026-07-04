terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  # Local backend, isolated per environment. Swap for s3/gcs/azurerm or an
  # HCP Terraform `cloud {}` block in a real team setup (see README).
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "docker" {}

module "web" {
  source = "../../modules/web_service"

  service_name = var.service_name
  environment  = "dev"
  instances    = var.instances

  extra_labels = {
    cost-center = "engineering"
  }
}
