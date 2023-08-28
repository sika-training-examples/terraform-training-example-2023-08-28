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

locals {
  aks_name       = "example"
  aks_node_count = 3
  aks_node_size  = "Standard_D2_v2"
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

  name       = local.aks_name
  dns_prefix = local.aks_name

  default_node_pool {
    name       = "default"
    node_count = local.aks_node_count
    vm_size    = local.aks_node_size
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
