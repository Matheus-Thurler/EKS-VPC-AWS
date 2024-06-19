# Definição do provider (por exemplo, AWS)
provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  config_path    = var.config_path
  config_context = var.config_context
}
