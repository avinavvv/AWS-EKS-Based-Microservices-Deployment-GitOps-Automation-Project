terraform {
  backend "s3" {
    bucket       = "devopsdock-terraform-backend-bucket-30102026"
    key          = "terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.71.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

