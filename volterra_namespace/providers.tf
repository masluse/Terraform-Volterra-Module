# Needed because the Volterra provider is not a Terraform official provider
terraform {
  required_providers {
    volterra = {
      source = "volterraedge/volterra"
    }
  }
}