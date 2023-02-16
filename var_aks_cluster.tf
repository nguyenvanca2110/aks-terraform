variable "resource_group_name" {
  default = "terraform-rg"
}

variable "acr_resource_group_name" {
  default = "terraform-rg"
}

variable "resource_group_name_for_role_assignment" {
  default = null
}

variable "location" {
  default = "southeastasia"
}

variable "aks_name" {
  description = "AKS cluster name"
  type        = string
  default     = "azure-sg-aks-rbmvb-uat-prv-001"
}

variable "acr_name" {
  description = "ACR name"
  type        = string
  default     = "azuresgacrrbmvbuat001"
}

variable "dns_prefix_private_cluster" {
  description = "Optional DNS prefix to use with hosted Kubernetes API server FQDN."
  type        = string
  default     = "azure-sg-aks-rbmvb-uat-prv-001-dns"
}

variable "sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free."
  type        = string
  default     = "Free"
}

########## Agent pool config ##################
variable "default_node_pool_config" {
  default = {
    name                 = "agentpool"
    orchestrator_version = null
    node_count           = 1
    vm_size              = "Standard_D4s_v3"
    os_disk_size_gb      = 128
    agent_subnet = {
      subnet_name = "azure-sg-snet-rbmvb-uat-prv-002"
      vnet_name   = "azure-sg-vnet-rbmvb-uat"
    }
    enable_auto_scaling = true
    max_count           = 2
    min_count           = 1
    availability_zones  = ["2", "3"]
    type                = "VirtualMachineScaleSets"
    max_pods            = 50
    tags                = {}
  }
}

##########################################################
################ Networking ####################
variable "network_profile_config" {
  default = {
    network_plugin     = "azure"
    network_policy     = "azure"
    dns_service_ip     = null
    docker_bridge_cidr = null
    pod_cidr           = null
    service_cidr       = null
    outbound_type      = "loadBalancer"
  }
}
########################################################
################# virtual node aci #####################
#variable "aci_connector_linux" {
#  default = {
#    virtual_node_enabled = true,
#    subnet_name          = "azure-sg-snet-rbmvb-uat-prv-001"
#    vnet_name            = "azure-sg-vnet-rbmvb-uat"
#  }
#}

#######################################################
##################### RBAC #######################
variable "enable_role_based_access_control" {
  description = "Enable Role Based Access Control."
  type        = bool
  default     = true
}

variable "rbac_aad_managed" {
  description = "Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration."
  type        = bool
  default     = true
}

variable "rbac_aad_admin_group_object_ids" {
  description = "Object ID of groups with admin access."
  type        = list(string)
  default     = null
}

#variable "rbac_aad_client_app_id" {
#  description = "The Client ID of an Azure Active Directory Application."
#  type        = string
#  default     = null
#}
#
#variable "rbac_aad_server_app_id" {
#  description = "The Server ID of an Azure Active Directory Application."
#  type        = string
#  default     = null
#}
#
#variable "rbac_aad_server_app_secret" {
#  description = "The Server Secret of an Azure Active Directory Application."
#  type        = string
#  default     = null
#}

variable "azure_policy_enabled" {
  description = "Is the Azure Policy for Kubernetes Add On enabled?"
  default     = false
}

#############################################
################## Monitoring ###############
variable "enable_log_analytics_workspace" {
  type        = bool
  description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = true
}
variable "cluster_log_analytics_workspace_name" {
  description = "(Optional) The name of the Analytics workspace"
  type        = string
  default     = null
}

variable "aks_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.21.2"
}

variable "private_cluster_enabled" {
  default = true
}

variable "tags" {
  default = {}
}

variable "acr_config" {
  default = {
    azuresgacrrbmvbuat001 = {
      sku                           = "Standard"
      admin_enabled                 = false
      public_network_access_enabled = true
      georeplications = [
        {
          location = "eastasia"
          zone_redundancy_enabled = true
        }
      ]
      tags                          = {}
    }
  }
}

variable "enable_acrpull_role" {
  type        = bool
  description = "Enable the AcrPull roll assignment for AKS cluster or not"
  default     = false
}

variable "defaults" {}
