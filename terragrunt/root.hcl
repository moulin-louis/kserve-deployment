generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    scaleway = {
      source = "scaleway/scaleway"
      version = "2.57.0"
    }
  }
}

provider "kubernetes" {
  host  = var.k8s_host
  token = var.k8s_token
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host  = var.k8s_host
    token = var.k8s_token
    cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
  }
}
EOF
}
