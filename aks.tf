# Get agent pool subnet  data source
data "azurerm_subnet" "agent_pool_subnet" {
  name                 = var.default_node_pool_config.agent_subnet.subnet_name
  virtual_network_name = var.default_node_pool_config.agent_subnet.vnet_name
  resource_group_name  = lookup(var.default_node_pool_config.agent_subnet, "resource_group_name", var.resource_group_name)
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                    = var.aks_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix_private_cluster
  kubernetes_version      = var.aks_version
  private_cluster_enabled = var.private_cluster_enabled
  sku_tier                = var.sku_tier

  default_node_pool {
    name                   = var.default_node_pool_config.name
    orchestrator_version   = lookup(var.default_node_pool_config, "orchestrator_version", null)
    vm_size                = var.default_node_pool_config.vm_size
    os_disk_size_gb        = lookup(var.default_node_pool_config, "os_disk_size_gb", null)
    vnet_subnet_id         = data.azurerm_subnet.agent_pool_subnet.id
    enable_auto_scaling    = var.default_node_pool_config.enable_auto_scaling
    node_count             = var.default_node_pool_config.node_count
    max_count              = var.default_node_pool_config.enable_auto_scaling ? var.default_node_pool_config.max_count : null
    min_count              = var.default_node_pool_config.enable_auto_scaling ? var.default_node_pool_config.min_count : null
    max_pods               = lookup(var.default_node_pool_config, "max_pods", null)
    availability_zones     = lookup(var.default_node_pool_config, "availability_zones", null)
    type                   = lookup(var.default_node_pool_config, "type", null)
    enable_host_encryption = lookup(var.default_node_pool_config, "enable_host_encryption", null)
    tags                   = merge(var.defaults.tags, var.default_node_pool_config.tags)
  }
  addon_profile {
    #    aci_connector_linux {
    #      enabled     = var.aci_connector_linux.virtual_node_enabled
    #      subnet_name = var.aci_connector_linux.subnet_name
    #    }
    oms_agent {
      enabled                    = var.enable_log_analytics_workspace
      log_analytics_workspace_id = var.enable_log_analytics_workspace ? data.azurerm_log_analytics_workspace.log_workspace[0].id : null
    }
    azure_policy {
      enabled = var.azure_policy_enabled
    }
  }
  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_plugin     = var.network_profile_config.network_plugin
    network_policy     = var.network_profile_config.network_policy
    dns_service_ip     = lookup(var.network_profile_config, "dns_service_ip", null)
    docker_bridge_cidr = lookup(var.network_profile_config, "docker_bridge_cidr", null)
    pod_cidr           = lookup(var.network_profile_config, "pod_cidr", null)
    service_cidr       = lookup(var.network_profile_config, "service_cidr", null)
    outbound_type      = lookup(var.network_profile_config, "outbound_type", null)
  }
  role_based_access_control {
    enabled = var.enable_role_based_access_control

    dynamic "azure_active_directory" {
      for_each = var.enable_role_based_access_control && var.rbac_aad_managed ? ["rbac"] : []
      content {
        managed                = true
        admin_group_object_ids = var.rbac_aad_admin_group_object_ids
      }
    }
    #    dynamic "azure_active_directory" {
    #      for_each = var.enable_role_based_access_control && !var.rbac_aad_managed ? ["rbac"] : []
    #      content {
    #        managed           = false
    #        client_app_id     = var.rbac_aad_client_app_id
    #        server_app_id     = var.rbac_aad_server_app_id
    #        server_app_secret = var.rbac_aad_server_app_secret
    #      }
    #    }
  }
  tags = merge(
    { resource_type = "kubernetes_cluster", created_date = formatdate("DD/MM/YYYY hh:mm:ss", timestamp()) },
    var.defaults.tags, var.tags
  )
  lifecycle { ignore_changes = [tags["created_date"]] }
  depends_on = [data.azurerm_log_analytics_workspace.log_workspace]
}

data "azurerm_log_analytics_workspace" "log_workspace" {
  count               = var.enable_log_analytics_workspace ? 1 : 0
  name                = var.cluster_log_analytics_workspace_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_log_analytics_solution" "log_analystic_solution" {
  count                 = var.enable_log_analytics_workspace ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = data.azurerm_log_analytics_workspace.log_workspace[0].id
  workspace_name        = data.azurerm_log_analytics_workspace.log_workspace[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
  tags = merge(
    { resource_type = "log_analytics_solution", created_date = formatdate("DD/MM/YYYY hh:mm:ss", timestamp()) },
    var.defaults.tags, var.tags
  )
  lifecycle { ignore_changes = [tags["created_date"]] }
  depends_on = [data.azurerm_log_analytics_workspace.log_workspace]
}

resource "azurerm_container_registry" "acr" {
  for_each                      = var.acr_config
  name                          = each.key
  resource_group_name           = lookup(each.value, "resource_group_name", var.defaults.resource_group_name)
  location                      = lookup(each.value, "location", var.defaults.location)
  sku                           = each.value.sku
  admin_enabled                 = each.value.admin_enabled
  public_network_access_enabled = each.value.public_network_access_enabled

  dynamic "georeplications" {
    for_each = lookup(each.value, "georeplications", [])
    content {
      location                  = georeplications.value.location
      zone_redundancy_enabled   = lookup(georeplications.value, "zone_redundancy_enabled", null)
      regional_endpoint_enabled = lookup(georeplications.value, "regional_endpoint_enabled", null)
      tags                      = merge(lookup(georeplications.value, "tags", {}), var.defaults.tags)
    }
  }
  tags = merge(
    { resource_type = "container_registry", created_date = formatdate("DD/MM/YYYY hh:mm:ss", timestamp()) },
    var.defaults.tags, lookup(each.value, "tags", {})
  )
  lifecycle { ignore_changes = [tags["created_date"]] }
}
