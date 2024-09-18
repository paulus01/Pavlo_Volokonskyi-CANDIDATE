resource "azurerm_resource_group" "pavlo-candidate-rg" {
  location = var.resource_group_location
  name     = "Pavlo_Candidate"
}

output "resource_group_name" {
  value = azurerm_resource_group.pavlo-candidate-rg.name
}
