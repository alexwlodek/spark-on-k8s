variable "release_name" {
  description = "Helm release name for Spark Operator"
  type        = string
  default     = "spark-operator"
}

variable "namespace" {
  description = "Namespace where Spark Operator will be installed"
  type        = string
  default     = "spark-operator"
}

variable "spark_job_namespaces" {
  description = "Namespaces where SparkApplication jobs will be allowed to run"
  type        = list(string)
}

variable "chart_version" {
  description = "Version of the Spark Operator helm chart (optional)"
  type        = string
  default     = null
}


