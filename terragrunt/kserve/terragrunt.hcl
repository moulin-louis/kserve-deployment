terraform {
  source = "../../modules/kserve/"
}

dependency "k8s_cluster" {
  config_path = "../k8s-cluster/"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  k8s_host                   = dependency.k8s_cluster.outputs.k8s_host
  k8s_token                  = dependency.k8s_cluster.outputs.k8s_token
  k8s_cluster_ca_certificate = dependency.k8s_cluster.outputs.k8s_cluster_ca_certificate
}
