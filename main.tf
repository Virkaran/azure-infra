# Resource Group

resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-rg"
  location = var.location
  tags     = var.tags
}


# Azure Key Vault

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.project_name}-kv"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "sp_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "get", "list", "set", "delete", "recover", "backup", "restore"
  ]
}



# Azure Container Registry (ACR)

resource "azurerm_container_registry" "acr" {
  name                = replace("${var.project_name}acr", "-", "")
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku
  admin_enabled       = false
  tags                = var.tags
}


# Networking: VNet + Subnet

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.project_name}-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr]
  delegation {
    name = "aks-delegation"
    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}


# Log Analytics Workspace

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.project_name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}


# AKS Cluster (Managed Identity)

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.project_name}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.project_name

  kubernetes_version = var.kubernetes_version != "" ? var.kubernetes_version : null

  default_node_pool {
    name           = "system"
    node_count     = var.aks_node_count
    vm_size        = var.aks_node_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }

  tags = var.tags
}


# Allow AKS kubelet to pull images from ACR

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}


# Public IP for Ingress (optional, for NGINX/AAG)

resource "azurerm_public_ip" "ingress" {
  name                = "${var.project_name}-ingress-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
