resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}
resource "helm_release" "kube-prometheus" {
  name       = "prom-operator"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace = kubernetes_namespace.monitoring.metadata.0.name

  values = [
    "${file("${path.module}/monitoring/custom_values.yaml")}"
  ]

  depends_on = [ 
    kubernetes_config_map.grafana-dashboards-app
   ]
}

resource "kubernetes_config_map" "grafana-dashboards-app" {
  metadata {
    name = "grafana-dashboard-app"
    namespace = kubernetes_namespace.monitoring.metadata.0.name

    labels = {
      grafana_dashboard = 1
    }

    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/app"
    }
  }

  data = {
    "all.json" = file("${path.module}/monitoring/dashboards/all.json"),
  }
}