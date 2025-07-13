resource "helm_release" "knative_operator" {
  name             = "knative-operator"
  chart            = "knative-operator"
  repository       = "https://knative.github.io/operator"
  namespace        = "knative-operator"
  create_namespace = true
}
