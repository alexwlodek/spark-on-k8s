locals {
  base_values = {
    # Lista namespace'ów, w których operator może uruchamiać SparkApplication
    spark = {
      jobNamespaces = var.spark_job_namespaces
    }

    
    webhook = {
      enable = var.webhook_enabled
    }
  }
    # Opcjonalnie ustawiamy tag obrazu, jeśli podano chart_version
    # Jeśli chart_version == null, zostawiamy pustą mapę (operator użyje domyślnej wersji)
 image_override = var.image_tag != null ? {
    image = {
      tag = var.image_tag
    }
  } : {}

  # Użytkownik może dostarczyć dowolne dodatkowe wartości przekazywane do chartu
  merged_values = merge(local.base_values, local.image_override, var.additional_values)
}

resource "helm_release" "spark_operator" {
  count            = var.enabled ? 1 : 0
  name             = var.release_name
  namespace        = var.namespace
  chart            = var.chart_name
  repository       = var.chart_repository
  version          = var.chart_version
  create_namespace = var.create_namespace

  # Zamiast set/dynamic set – klasyczne values z yamlencode
  values = [
    yamlencode(local.merged_values)
  ]
}
