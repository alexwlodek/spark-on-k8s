output "namespace" {
  description = "Namespace where Spark Operator is installed"
  value       = var.namespace
}

output "release_name" {
  description = "Spark Operator Helm release name"
  value       = helm_release.spark_operator.name
}
