locals {
  # Values przekazywane do helm chartu spark-operator
  spark_operator_values = {
    # Lista namespace'ów, w których operator może uruchamiać SparkApplication
    spark = {
      jobNamespaces = var.spark_job_namespaces
    }

    # Wyłączamy webhook na początek (prościej do testów)
    webhook = {
      enable = false
    }

    # Opcjonalnie ustawiamy tag obrazu, jeśli podano chart_version
    # Jeśli chart_version == null, zostawiamy pustą mapę (operator użyje domyślnej wersji)
    image = var.chart_version != null ? {
      tag = var.chart_version
    } : {}
  }
}

resource "helm_release" "spark_operator" {
  name             = var.release_name
  namespace        = var.namespace
  chart            = "spark-operator"
  repository       = "https://kubeflow.github.io/spark-operator"
  create_namespace = true

  # Zamiast set/dynamic set – klasyczne values z yamlencode
  values = [
    yamlencode(local.spark_operator_values)
  ]
}
