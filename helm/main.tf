data "azurerm_resource_group" "pavlo-candidate-rg" {
  name = "Pavlo_Candidate"
}

data "azurerm_kubernetes_cluster" "credentials" {
  name                = "pavlo-candidate-aks1"
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

data "azurerm_resource_group" "aks" {
  name = "MC_Pavlo_Candidate_pavlo-candidate-aks1_northeurope"
}

data "azurerm_key_vault_secret" "mysecret" {
  name         = "mysecret"
  key_vault_id = data.azurerm_key_vault.vault.id
}

data "azurerm_key_vault" "vault" {
  name                = "pavlo-candidate"
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name

}
resource "helm_release" "aks_secret_provider" {
  name    = "aks-secret-provider"
  chart   = "./aks-secret-provider"
  version = "0.0.1"
  values = [yamlencode({
    vaultName = data.azurerm_key_vault.vault.name
    tenantId  = data.azurerm_key_vault.vault.tenant_id
    clientId  = data.azurerm_kubernetes_cluster.credentials.key_vault_secrets_provider[0].secret_identity[0].client_id
  })]
  force_update = true
}
