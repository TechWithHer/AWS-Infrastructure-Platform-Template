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
    key            = "stage/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "strenure-terraform-locktable"
    encrypt        = true
  }
}