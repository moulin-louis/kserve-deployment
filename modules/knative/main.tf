resource "helm_release" "knative_operator" {
  name             = "knative-operator"
  chart            = "knative-operator"
  repository       = "https://knative.github.io/operator"
  namespace        = "knative-operator"
  create_namespace = true
}

resource "kubernetes_namespace" "knative_serving_namespace" {
  metadata {
    name = "knative-serving"
    labels = {
      "istio-injection" = "enabled"
    }
  }
  depends_on = [helm_release.knative_operator]
}

resource "kubernetes_manifest" "knative_serving_deployment" {
  manifest = {
    apiVersion = "operator.knative.dev/v1beta1"
    kind       = "KnativeServing"
    metadata = {
      name      = "knative-serving"
      namespace = "knative-serving"
    }
  }
  depends_on = [kubernetes_namespace.knative_serving_namespace]
}

# Kubernetes Job for default-domain
resource "kubernetes_job_v1" "default_domain" {
  metadata {
    name      = "default-domain"
    namespace = "knative-serving"

    labels = {
      app                           = "default-domain"
      "app.kubernetes.io/component" = "default-domain-job"
      "app.kubernetes.io/name"      = "knative-serving"
      "app.kubernetes.io/version"   = "1.18.1"
    }
  }

  spec {
    backoff_limit = 10

    template {
      metadata {
        labels = {
          app                           = "default-domain"
          "app.kubernetes.io/component" = "default-domain-job"
          "app.kubernetes.io/name"      = "knative-serving"
          "app.kubernetes.io/version"   = "1.18.1"
          "sidecar.istio.io/inject"     = "false"
        }
      }

      spec {
        service_account_name = "controller"
        restart_policy       = "Never"

        container {
          name  = "default-domain"
          image = "gcr.io/knative-releases/knative.dev/serving/cmd/default-domain@sha256:fb6d54070b69c90b25c8a5d76954fba8182d9fbab391287f25619e18852de834"
          args  = ["-magic-dns=sslip.io"]

          port {
            name           = "http"
            container_port = 8080
          }

          readiness_probe {
            http_get {
              port = 8080
            }
          }

          liveness_probe {
            http_get {
              port = 8080
            }
            failure_threshold = 6
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "1000Mi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true

            capabilities {
              drop = ["ALL"]
            }

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "SYSTEM_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
        }
      }
    }
  }
}

# Kubernetes Service for default-domain
resource "kubernetes_service_v1" "default_domain_service" {
  metadata {
    name      = "default-domain-service"
    namespace = "knative-serving"

    labels = {
      app                           = "default-domain"
      "app.kubernetes.io/component" = "default-domain-job"
      "app.kubernetes.io/name"      = "knative-serving"
      "app.kubernetes.io/version"   = "1.18.1"
    }
  }

  spec {
    selector = {
      app = "default-domain"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}
