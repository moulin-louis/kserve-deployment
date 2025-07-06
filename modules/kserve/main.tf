resource "helm_release" "kserve_crd" {
  name             = "kserve-crd"
  namespace        = "kserve"
  chart            = "kserve-crd"
  repository       = "oci://ghcr.io/kserve/charts/"
  version          = "v0.15.0"
  create_namespace = true
  wait             = true
}

resource "helm_release" "kserve_resources" {
  name             = "kserve"
  namespace        = "kserve"
  chart            = "kserve"
  repository       = "oci://ghcr.io/kserve/charts/"
  version          = "v0.15.0"
  create_namespace = true
  wait             = true
}
