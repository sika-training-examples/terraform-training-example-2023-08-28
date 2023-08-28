terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.71.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  location = "westeurope"
  common_tags = {
    foo = "bar"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "example"
  location = local.location
  tags     = merge(local.common_tags, )
  lifecycle { ignore_changes = [tags] }
}
