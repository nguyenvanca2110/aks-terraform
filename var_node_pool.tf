variable "node_pool_config" {
  default = {
    mainservice = {
      mode    = "User",
      os_type = "Linux",
      pod_subnet = {
        vnet_name = "azure-sg-vnet-rbmvb-uat",
        subnet_name    = "azure-sg-snet-rbmvb-uat-prv-004"
      }
      vm_size               = "Standard_DS2_v2"
      enable_node_public_ip = false,
      enable_auto_scaling   = true,
      node_count            = 1
      max_count             = 2,
      min_count             = 1,
      max_pods              = 30,
      os_disk_size_gb       = 128,
      os_disk_type          = "Managed",
      availability_zones    = ["1", "2"],
      orchestrator_version   = "1.21.2",
      node_labels           = { "kubelet.kubernetes.io/hostname" : "main-service-linux" },
      tags = {
        created_by = "cuong.truonghoang@vib.com.vn"
      }
    }
#    utils = {
#
#    }
#    backoffice = {
#
#    }
  }
}