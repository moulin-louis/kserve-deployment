resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  namespace        = "cert-manager"
  version          = "1.18.2"
  create_namespace = true
  set = [
    {
      name  = "crds.enabled"
      value = "true"

    }
  ]
  wait = true
}
