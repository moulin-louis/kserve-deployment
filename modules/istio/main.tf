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
#

resource "null_resource" "gateway_api_install" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml"
  }
  depends_on = [helm_release.istiod]
  triggers = {
    "version" : timestamp()
  }
}

resource "kubernetes_labels" "enable_istio_default_ns" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "default"
  }
  labels = {
    istio-injection = "enabled"
  }
}

resource "kubernetes_manifest" "telemetry_istio" {
  manifest = {
    apiVersion = "telemetry.istio.io/v1"
    kind       = "Telemetry"
    metadata = {
      name      = "mesh-default"
      namespace = "istio-system"
    }
    spec = {
      accessLogging = [
        {
          providers = [
            { name = "envoy" }
          ]
        }
      ]
    }
  }
  depends_on = [helm_release.istiod]

}
