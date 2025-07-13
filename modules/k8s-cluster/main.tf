resource "scaleway_vpc" "vpc01" {
  name                             = "dev-vpc"
  enable_routing                   = true
  enable_custom_routes_propagation = true
  tags                             = ["terraform", "dev"]
}

resource "scaleway_vpc_private_network" "pn_priv" {
  name                             = "dev-vpc"
  vpc_id                           = scaleway_vpc.vpc01.id
  enable_default_route_propagation = true
  ipv4_subnet {
    subnet = "172.16.12.0/22"
  }
  tags = ["dev", "terraform"]
}

resource "scaleway_vpc_public_gateway_ip" "main" {
}

resource "scaleway_vpc_public_gateway" "pg01" {
  name  = "dev_public_gateway"
  type  = "VPC-GW-S"
  ip_id = scaleway_vpc_public_gateway_ip.main.id
  tags  = ["dev", "terraform"]
}

resource "scaleway_vpc_gateway_network" "main" {
  gateway_id         = scaleway_vpc_public_gateway.pg01.id
  private_network_id = scaleway_vpc_private_network.pn_priv.id
  enable_masquerade  = true
  ipam_config {
    push_default_route = true
  }
}

resource "scaleway_k8s_cluster" "this" {
  name                        = "dev-cluster"
  delete_additional_resources = true
  cni                         = "cilium"
  version                     = "1.32.3"
  private_network_id          = scaleway_vpc_private_network.pn_priv.id
  tags                        = ["dev", "terraform"]
  depends_on                  = [scaleway_vpc_gateway_network.main]
}

resource "scaleway_k8s_pool" "dev_cluster" {
  cluster_id         = scaleway_k8s_cluster.this.id
  name               = "dev-node-pool"
  node_type          = "DEV1-L"
  size               = 2
  min_size           = 2
  max_size           = 4
  autohealing        = true
  autoscaling        = true
  public_ip_disabled = true
  tags               = ["dev", "terraform"]
}
