locals {
  node_pool_subnets = distinct([
    for node_pool, cfg in var.node_pool_config : {
      subnet_name         = cfg.subnet.subnet_name,
      vnet_name           = cfg.subnet.vnet_name,
      resource_group_name = lookup(cfg.subnet, "resource_group_name", var.resource_group_name)
    }
    if lookup(cfg, "subnet", null) != null
  ])
}

data "azurerm_subnet" "node_pool_subnets" {
  count                = length(local.node_pool_subnets)
  name                 = local.node_pool_subnets[count.index].subnet_name
  virtual_network_name = local.node_pool_subnets[count.index].vnet_name
  resource_group_name  = local.node_pool_subnets[count.index].resource_group_name
}
locals {
  node_pool_subnet_id = { for subnet in data.azurerm_subnet.node_pool_subnets : subnet.name => subnet.id }
}

resource "azurerm_kubernetes_cluster_node_pool" "aks_node_pools" {
  for_each               = var.node_pool_config
  name                   = each.key
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size                = each.value.vm_size
  mode                   = lookup(each.value, "mode", null)
  os_type                = lookup(each.value, "os_type", null)
  vnet_subnet_id          = lookup(each.value, "subnet", null) != null ? lookup(local.node_pool_subnet_id, each.value.subnet.subnet_name, null) : null
  enable_auto_scaling    = lookup(each.value, "enable_auto_scaling", null)
  enable_node_public_ip  = lookup(each.value, "enable_node_public_ip", null)
  node_count             = lookup(each.value, "node_count", null)
  max_count              = lookup(each.value, "max_count", null)
  min_count              = lookup(each.value, "min_count", null)
  max_pods               = lookup(each.value, "max_pods", null)
  os_disk_size_gb        = lookup(each.value, "os_disk_size_gb", null)
  os_disk_type           = lookup(each.value, "os_disk_type", null)
  availability_zones     = lookup(each.value, "availability_zones", null)
  orchestrator_version    = lookup(each.value, "orchestrator_version", null)
  node_labels            = lookup(each.value, "node_labels", null)
  enable_host_encryption = lookup(each.value, "enable_host_encryption", null)
  tags = merge(
    { resource_type = "kubernetes_cluster_node_pool", created_date = formatdate("DD/MM/YYYY hh:mm:ss", timestamp()) },
    var.defaults.tags, lookup(each.value, "tags", {})
  )
  lifecycle { ignore_changes = [tags["created_date"]] }
  depends_on             = [azurerm_kubernetes_cluster.aks_cluster]
}