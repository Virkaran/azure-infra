project_name       = "microshop"
location           = "centralindia"
acr_sku            = "Basic"

vnet_address_space = ["10.20.0.0/16"]
subnet_cidr        = "10.20.1.0/24"

aks_node_count     = 2
aks_node_size      = "Standard_D2s_v5"

tags = {
  env        = "dev"
  owner      = "karanvir"
  managed-by = "terraform"
}
