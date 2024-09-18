# data "azurerm_resource_group" "pavlo-candidate-rg" {
#   name = "Pavlo_Candidate"
# }

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

# data "azurerm_kubernetes_cluster" "pavlo-candidate" {
#   name                = "pavlo-candidate"
#   resource_group_name = "MC_Pavlo_Candidate_pavlo-candidate-aks1_northeurope"
# }


resource "azurerm_public_ip" "nginx_ingress" {
  name                = "nginx-ingress-pip"
  location            = data.azurerm_resource_group.aks.location
  resource_group_name = data.azurerm_resource_group.aks.name
  allocation_method   = "Static"
}

resource "helm_release" "ingress" {
  # depends_on       = [azurerm_key_vault_access_policy.aks_access_to_kv]
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx/"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true


  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.nginx_ingress.ip_address
  }
}

resource "azurerm_dns_zone" "pavlo-candidate" {
  name                = "hw.pavlo-candidate.uk"
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
}

resource "azurerm_dns_a_record" "pavlo-candidate" {
  name                = "lb"
  zone_name           = azurerm_dns_zone.pavlo-candidate.name
  resource_group_name = data.azurerm_resource_group.pavlo-candidate-rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.nginx_ingress.id
}
