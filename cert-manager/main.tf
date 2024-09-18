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

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
    # chart            = "./cert-manager.crds.yaml"
    chart = "${path.module}/cert-manager"
  create_namespace = true
    set {
      name  = "installCRDs"
      value = "true"
    }
}
