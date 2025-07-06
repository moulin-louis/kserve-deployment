resource "helm_release" "istio_base" {
  name             = "istio-base"
  chart            = "base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = true
  wait             = true
}

resource "helm_release" "istiod" {
  name             = "istiod"
  chart            = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = false
  wait             = true
  depends_on       = [helm_release.istio_base]
}

resource "helm_release" "istio-ingress" {
  name             = "istio-ingressgateway"
  chart            = "gateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  wait             = true
  create_namespace = false
  depends_on       = [helm_release.istiod]
}
