resource "kubernetes_namespace" "knative_serving_namespace" {
  metadata {
    name = "knative-serving"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_manifest" "knative_serving_deployment" {
  manifest = {
    apiVersion = "operator.knative.dev/v1beta1"
    kind       = "KnativeServing"
    metadata = {
      name      = "knative-serving"
      namespace = "knative-serving"
    }
    spec = {
      config = {
        domain = {
          "kserve-loulou.eu" : ""
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.knative_serving_namespace]
}
