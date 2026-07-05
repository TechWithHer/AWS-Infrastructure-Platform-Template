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
    bucket         = "techwithher-2026-s3"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "techwithher-locktable"
    encrypt        = true
  }
}

provider "docker" {}
provider "aws" {
  region = "ap-south-1"
}
module "networking" {

  source = "../../modules/networking"

  project_name = "multi-env-platform"
  environment  = "dev"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_1_cidr = "10.0.1.0/24"
  public_subnet_2_cidr = "10.0.2.0/24"

  availability_zone_1 = "ap-southeast-1a"
  availability_zone_2 = "ap-southeast-1b"
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
