output "k8s_host" {
  value     = scaleway_k8s_cluster.this.kubeconfig[0].host
  sensitive = true
}

output "k8s_token" {
  value     = scaleway_k8s_cluster.this.kubeconfig[0].token
  sensitive = true
}

output "k8s_cluster_ca_certificate" {
  value     = scaleway_k8s_cluster.this.kubeconfig[0].cluster_ca_certificate
  sensitive = true
}
