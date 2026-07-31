terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "techwithher-project-2-statelock"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "techwithher-project-2-locktable"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "networking" {
  source = "../../modules/networking"

  project_name = "aws-multi-env-platform"
  environment  = "dev"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_1_cidr = "10.0.1.0/24"
  public_subnet_2_cidr = "10.0.2.0/24"

  availability_zone_1 = "ap-southeast-1a"
  availability_zone_2 = "ap-southeast-1b"
}
#---------------------

module "compute" {

  source = "../../modules/compute"

  project_name = "aws-multi-env-platform"

  environment = "dev"

  vpc_id = module.networking.vpc_id

  subnet_id     = module.networking.public_subnet_ids[0]
  instance_type = "t3.micro"
}

module "monitoring" {

  source = "../../modules/monitoring"

  project_name = "aws-multi-env-platform"

  environment = "dev"

  instance_id = module.compute.instance_id

  alarm_email = "teamayushisingh@gmail.com"
}

module "operations_lambda" {

  source = "../../modules/lambda"

  project_name = "aws-multi-env-platform"

  environment = "dev"

  aws_region = "ap-southeast-1"
}