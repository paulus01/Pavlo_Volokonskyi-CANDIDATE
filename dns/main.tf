# data "azurerm_resource_group" "pavlo-candidate-rg" {
#   name = "Pavlo_Candidate"
# }

data "azurerm_resource_group" "pavlo-candidate-rg" {
  name = "Pavlo_Candidate"
}

data "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "my-terraform-PublicIP"
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
}

data "azurerm_dns_zone" "pavlo-candidate" {
  name                = "hw.pavlo-candidate.uk"
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
}

resource "azurerm_dns_a_record" "pavlo-candidate" {
  name                = "jenkins"
  zone_name           = data.azurerm_dns_zone.pavlo-candidate.name
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
  ttl                 = 300
  target_resource_id  = data.azurerm_public_ip.my_terraform_public_ip.id
}
