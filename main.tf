terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.71.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.13.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "cloudflare_api_token" {}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
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

resource "azurerm_public_ip" "ingress" {
  name                = "example-ingress"
  resource_group_name = azurerm_kubernetes_cluster.example.node_resource_group
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(local.common_tags, )
  lifecycle { ignore_changes = [tags] }
}

variable "cloudflare_zone_id" {}

resource "cloudflare_record" "ingress" {
  zone_id = var.cloudflare_zone_id
  name    = "ondrejsika"
  value   = azurerm_public_ip.ingress.ip_address
  type    = "A"
}

resource "cloudflare_record" "ingress_wildcard" {
  zone_id = var.cloudflare_zone_id
  name    = "*.${cloudflare_record.ingress.name}"
  value   = cloudflare_record.ingress.hostname
  type    = "CNAME"
}

output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.example.kube_config_raw
  sensitive = true
}


output "ingress_resource_group_name" {
  value = azurerm_public_ip.ingress.resource_group_name
}

output "ingress_ip" {
  value = azurerm_public_ip.ingress.ip_address
}
