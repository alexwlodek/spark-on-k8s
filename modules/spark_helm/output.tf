output "namespace" {
  description = "Namespace where Spark Operator is installed"
  value       = var.namespace
}

output "release_name" {
  description = "Spark Operator Helm release name"
  value       = var.enabled ? helm_release.spark_operator[0].name : null
}
