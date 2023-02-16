output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw

  sensitive = true
}
output "aks_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.aks_cluster.fqdn
}

output "aks_node_rg" {
  value = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}

output "aks_kubelet_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity.0.object_id
}