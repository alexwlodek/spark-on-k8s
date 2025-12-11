variable "spark_namespace_name" {
  description = "Namespace for Spark jobs"
  type        = string
  default     = "spark"
}

variable "spark_service_account_name" {
  description = "ServiceAccount name used by Spark jobs"
  type        = string
  default     = "spark-sa"
}

variable "spark_sa_role_name" {
  description = "Role name bound to the Spark ServiceAccount"
  type        = string
  default     = "spark-sa-role"
}

variable "spark_sa_role_binding_name" {
  description = "RoleBinding name connecting the Spark ServiceAccount to its role"
  type        = string
  default     = "spark-sa-binding"
}


variable "spark_irsa_role_arn" {
  description = "IAM role ARN used by Spark jobs via IRSA"
  type        = string
}

variable "spark_operator_namespace" {
  description = "Namespace where Spark Operator is installed"
  type        = string
  default     = "spark-operator"
}

variable "spark_operator_sa_name" {
  description = "ServiceAccount name used by Spark Operator controller"
  type        = string
  default     = "spark-operator-controller"
}