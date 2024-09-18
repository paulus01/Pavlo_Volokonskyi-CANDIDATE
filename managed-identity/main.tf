data "azurerm_resource_group" "pavlo-candidate-rg" {
  name = "Pavlo_Candidate"
}


locals {
  identity_name = "pavlo-candidate"
  namespace            = "pavlo-candidate"
  service_account_name = "cert-manager"
}

resource "azurerm_user_assigned_identity" "pavlo-candidate" {
  name                = local.identity_name
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
}

resource "azurerm_federated_identity_credential" "pavlo-candidate" {
  name                = local.identity_name
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.kubernetes_oidc_issuer_url // Use the output from above or if in the same file
  parent_id           = azurerm_user_assigned_identity.example_worker.id
  subject             = "system:serviceaccount:${local.namespace}:${local.service_account_name}"
}
