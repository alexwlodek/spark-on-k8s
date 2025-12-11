output "namespace" {
  value       = kubernetes_namespace.ci.metadata[0].name
  description = "Namespace where Jenkins is installed"
}

output "service_name" {
  value       = "jenkins"
  description = "Service name of Jenkins controller"
}
