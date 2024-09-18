data "azurerm_kubernetes_cluster" "credentials" {
  name                = azurerm_kubernetes_cluster.pavlo-candidate.name
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
}

data "azurerm_container_registry" "pavlo-candidate" {
  name                = "pavloCandidate"
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.credentials.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.cluster_ca_certificate)

  }
}

variable "subscription_id" {
}

data "azurerm_resource_group" "pavlo-candidate-rg" {
  name = "Pavlo_Candidate"
}

data "azurerm_key_vault" "vault" {
  name                = "pavlo-candidate"
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name

}

resource "azurerm_kubernetes_cluster" "pavlo-candidate" {
  name                             = "pavlo-candidate-aks1"
  location                         = data.azurerm_resource_group.pavlo-candidate-rg.location
  resource_group_name              = data.azurerm_resource_group.pavlo-candidate-rg.name
  dns_prefix                       = "pavlocandidateaks1"
  http_application_routing_enabled = true
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "pavlo-candidate"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

}

resource "azurerm_key_vault_access_policy" "vaultaccess" {
  key_vault_id = data.azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_key_vault.vault.tenant_id
  object_id    = azurerm_kubernetes_cluster.pavlo-candidate.key_vault_secrets_provider[0].secret_identity[0].object_id
  secret_permissions = [
    "Get", "List"
  ]
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.pavlo-candidate.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.pavlo-candidate.kube_config_raw

  sensitive = true
}

output "kubernetes_oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.pavlo-candidate.oidc_issuer_url
}

resource "azurerm_dns_zone" "pavlo-candidate" {
  name                = "pavlo-candidate.uk"
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
}

resource "azurerm_role_assignment" "pavlo-candidate" {
  principal_id                     = azurerm_kubernetes_cluster.pavlo-candidate.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.pavlo-candidate.id
  skip_service_principal_aad_check = true
}