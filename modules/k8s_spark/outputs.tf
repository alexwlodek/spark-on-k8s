output "namespace" {
  description = "Namespace where Spark applications run"
  value       = kubernetes_namespace.spark.metadata[0].name
}

output "service_account_name" {
  description = "Service account name for Spark jobs"
  value       = kubernetes_service_account.spark_sa.metadata[0].name
}
