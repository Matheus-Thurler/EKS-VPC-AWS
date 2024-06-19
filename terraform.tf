# Configurações globais do Terraform

terraform {
  required_version = ">= 1.0.0"

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  # backend "s3" {
  #   bucket         = "mycomponents-tfstate"
  #   key            = "state/terraform.tfstate"
  #   region         = var.region
  #   encrypt        = true
  #   dynamodb_table = "mycomponents_tf_lockid"
  # }
}
