terraform {
  source = "../../modules/istio/"
}

dependency "k8s_cluster" {
  config_path = "../k8s-cluster/"
  mock_outputs = {
    k8s_token = "PLACEHOLDER_TOKEN"
    k8s_host = "PLACEHOLDER_HOST"
    k8s_cluster_ca_certificate = "UExBQ0VIT0xERVJfQ0EK"
  }
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  k8s_host                   = dependency.k8s_cluster.outputs.k8s_host
  k8s_token                  = dependency.k8s_cluster.outputs.k8s_token
  k8s_cluster_ca_certificate = dependency.k8s_cluster.outputs.k8s_cluster_ca_certificate
}
