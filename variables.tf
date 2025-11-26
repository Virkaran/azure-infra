variable "project_name" {
  description = "Short name used as a prefix for resources"
  type        = string
  default     = "microshop"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "centralindia"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {
    env        = "dev"
    managed-by = "terraform"
  }
}

variable "acr_sku" {
  description = "ACR SKU (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
}

variable "vnet_address_space" {
  description = "VNET CIDR"
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "subnet_cidr" {
  description = "AKS subnet CIDR"
  type        = string
  default     = "10.20.1.0/24"
}

variable "aks_node_count" {
  description = "Default node count in AKS"
  type        = number
  default     = 2
}

variable "aks_node_size" {
  description = "AKS node size"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "kubernetes_version" {
  description = "AKS version (empty to use latest)"
  type        = string
  default     = ""
}
