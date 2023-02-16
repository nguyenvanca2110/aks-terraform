# Add AcrPull roll assignment for AKS
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
  depends_on = [azurerm_container_registry.acr]
}
resource "azurerm_role_assignment" "role_acrpull" {
  count                            = var.enable_acrpull_role ? 1 : 0
  scope                            = data.azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
  depends_on                       = [azurerm_container_registry.acr, azurerm_kubernetes_cluster.aks_cluster]
}

locals {
  rg_for_role_assignment = var.resource_group_name_for_role_assignment == null ? [] : [var.resource_group_name_for_role_assignment, "MC_${var.resource_group_name_for_role_assignment}_${var.aks_name}_${var.location}"]
}

# Add Network Contributor roll assignment for AKS
data "azurerm_resource_group" "rg_data_for_role_assignment" {
  count = length(local.rg_for_role_assignment)
  name  = local.rg_for_role_assignment[count.index]
  depends_on                       = [azurerm_kubernetes_cluster.aks_cluster]
}

resource "azurerm_role_assignment" "network_contributor_role" {
  count                            = length(data.azurerm_resource_group.rg_data_for_role_assignment)
  scope                            = data.azurerm_resource_group.rg_data_for_role_assignment[count.index].id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
  depends_on                       = [azurerm_kubernetes_cluster.aks_cluster]
}

#data "azurerm_user_assigned_identity" "aciconnectorlinux" {
#  name                = "aciconnectorlinux-${var.aks_name}"
#  resource_group_name = "MC_${var.acr_resource_group_name}_${var.aks_name}_${var.location}"
#}
#data "azurerm_virtual_network" "aciconnectorlinux_vnet" {
#  name                = var.aci_connector_linux.vnet_name
#  resource_group_name = var.acr_resource_group_name
#}

#resource "azurerm_role_assignment" "network_contributor_role_for_aciconnectorlinux" {
#  scope                            = data.azurerm_virtual_network.aciconnectorlinux_vnet.id
#  role_definition_name             = "Network Contributor"
#  principal_id                     = data.azurerm_user_assigned_identity.aciconnectorlinux.principal_id
#  depends_on                       = [azurerm_kubernetes_cluster.aks_cluster]
#}
