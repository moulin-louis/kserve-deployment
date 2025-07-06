resource "scaleway_vpc_private_network" "pn_priv" {
  name = "subnet_demo"
  tags = ["dev", "terraform"]
}

resource "scaleway_vpc_public_gateway" "main" {
  name = "public_gateway_demo"
  type = "VPC-GW-S"
  tags = ["dev", "terraform"]
}

resource "scaleway_k8s_cluster" "this" {
  name                        = "dev-cluster"
  delete_additional_resources = true
  cni                         = "cilium"
  version                     = "1.32.3"
  private_network_id          = scaleway_vpc_private_network.pn_priv.id
  tags                        = ["dev", "terraform"]
}

resource "scaleway_k8s_pool" "bill" {
  cluster_id  = scaleway_k8s_cluster.this.id
  name        = "dev-node-pool"
  node_type   = "DEV1-M"
  size        = 1
  min_size    = 1
  max_size    = 4
  autohealing = true
  autoscaling = true
  tags        = ["dev", "terraform"]
}
