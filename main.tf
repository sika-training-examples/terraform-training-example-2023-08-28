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

resource "azurerm_kubernetes_cluster" "example" {
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  name       = "example"
  dns_prefix = "example"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(local.common_tags, )
  lifecycle { ignore_changes = [tags] }
}

output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.example.kube_config_raw
  sensitive = true
}
