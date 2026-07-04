terraform {
  required_version = ">= 1.5.0" #Which version of Terraform is required to run this configuration.

  required_providers {
    docker = {
      source  = "kreuzwerker/docker" #Which provider to use for Docker resources.
      version = "~> 3.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate" 
    #Backend to store the Terraform state file locally. 
    #Note: The local backend stores the state file on the machine where Terraform is executed. 
    # In a real team setup, you might want to use a remote backend like Terraform Cloud, S3, GCS, or Azure.
  }
}

provider "docker" {}

module "web" {
  source = "../../modules/web_service"

  service_name = var.service_name
  environment  = "prod"
  instances    = var.instances

  extra_labels = {
    cost-center = "engineering"
    tier        = "production"
  }
}
