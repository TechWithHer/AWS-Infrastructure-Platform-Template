terraform {
  required_version = ">= v1.16.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "strenure-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "strenure-terraform-locktable"
    encrypt        = true
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
