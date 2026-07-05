terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ayushi-terraform-state-2026"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "docker" {}
provider "aws" {
  region = "ap-south-1"
}

module "web" {
  source = "../../modules/web_service"

  service_name = var.service_name
  environment  = "dev"
  instances    = var.instances

  extra_labels = {
    cost-center = "engineering"
  }
}
