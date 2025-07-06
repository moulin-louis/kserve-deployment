terraform {
  source = "../../modules/k8s-cluster/"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {}
