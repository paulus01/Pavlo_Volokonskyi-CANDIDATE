data "azurerm_resource_group" "pavlo-candidate-rg" {
  name = "Pavlo_Candidate"
}

resource "azurerm_container_registry" "pavlo-candidate" {
  name                = "pavloCandidate"
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
  location            = data.azurerm_resource_group.pavlo-candidate-rg.location
  sku                 = "Premium"
  admin_enabled       = false
}