provider "aws" {
  region = var.region
}

locals {
  project_name = "project"
  tags = {
    Name        = local.project_name
    Environment = "dev"
  }
}
