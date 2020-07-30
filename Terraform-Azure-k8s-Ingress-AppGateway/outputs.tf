output "client_key" {
  value = azurerm_kubernetes_cluster.az-k8s.kube_config.0.client_key
}


output "client_certificate" {
  value = azurerm_kubernetes_cluster.az-k8s.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.az-k8s.kube_config.0.cluster_ca_certificate
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.az-k8s.kube_config.0.username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.az-k8s.kube_config.0.password
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.az-k8s.kube_config_raw
}

output "host" {
  value = azurerm_kubernetes_cluster.az-k8s.kube_config.0.host
} 


output "identity_resource_id" {
    value = azurerm_user_assigned_identity.az-user-identity01.id
}

output "identity_client_id" {
    value = azurerm_user_assigned_identity.az-user-identity01.client_id
}