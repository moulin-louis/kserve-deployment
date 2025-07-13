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
  create_namespace = false
  set = [
    {
      name  = "kserve.controller.gateway.ingressGateway.enableGatewayApi"
      value = "true"
    },
    # {
    #   name  = "kserve.controller.gateway.ingressGateway.createGateway"
    #   value = "true"
    # },
    # {
    #   name  = "kserve.controller.gateway.ingressGateway.className"
    #   value = "istio"
    # }
  ]
  #https://github.com/kserve/kserve/pull/4544
  # postrender = {
  #   binary_path = "./patch-classname-gateway.sh"
  # }
  wait       = true
  depends_on = [helm_release.kserve_crd, kubernetes_manifest.kserve_ingress_gateway]
}

#create gateway by hand because of this
#https://github.com/kserve/kserve/pull/4544
resource "kubernetes_manifest" "kserve_ingress_gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"

    metadata = {
      name      = "kserve-ingress-gateway"
      namespace = "kserve"
      annotations = {

      }
    }

    spec = {
      gatewayClassName = "istio"

      listeners = [
        {
          name     = "http"
          protocol = "HTTP"
          port     = 80
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]

      infrastructure = {
        annotations = {
          "service.beta.kubernetes.io/scw-loadbalancer-private" = "true"

          "service.beta.kubernetes.io/scw-loadbalancer-proxy-protocol-v2" : "true"
          "proxy.istio.io/config" : "{\"gatewayTopology\" : { \"proxyProtocol\": {} }}"
        }
        labels = {
          "serving.kserve.io/gateway" = "kserve-ingress-gateway"
        }
      }
    }
  }
}

# resource "kubernetes_labels" "enable_istio_default_ns" {
#   api_version = "v1"
#   kind        = "Namespace"
#   metadata {
#     name = "kserve"
#   }
#   labels = {
#     istio-injection = "enabled"
#   }
#   depends_on = [helm_release.kserve_resources]
# }
#

