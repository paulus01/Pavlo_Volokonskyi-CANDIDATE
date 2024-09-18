data "azurerm_resource_group" "pavlo-candidate-rg" {
  name = "Pavlo_Candidate"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "vault" {
  name                = "pavlo-candidate"
  location            = data.azurerm_resource_group.pavlo-candidate-rg.location
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create",
    ]

    secret_permissions = [
      "Get", "List", "Set",
    ]

    storage_permissions = [
      "Get", "List", "Set",
    ]
  }
}

resource "azurerm_key_vault_secret" "mysecret" {
  name         = "mysecret"
  value        = "super_secret"
  key_vault_id = azurerm_key_vault.vault.id
}

