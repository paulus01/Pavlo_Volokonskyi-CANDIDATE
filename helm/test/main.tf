data "azurerm_resource_group" "pavlo-candidate-rg" {
  name = "Pavlo_Candidate"
}


data "azurerm_dns_zone" "pavlo-candidate" {
  name                = "pavlo-candidate.uk"
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
}

resource "azurerm_dns_cname_record" "pavlo-candidate" {
  name                = "lb-helloweb"
  zone_name           = data.azurerm_dns_zone.pavlo-candidate.name
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
  ttl                 = 300
  record              = "www"
}
