variable "release_name" {
  description = "Helm release name for Spark Operator"
  type        = string
  default     = "spark-operator"
}

variable "enabled" {
  description = "Whether to install the Spark Operator release"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Namespace where Spark Operator will be installed"
  type        = string
  default     = "spark-operator"
}

variable "create_namespace" {
  description = "Whether to create the namespace if it does not exist"
  type        = bool
  default     = true
}

variable "chart_name" {
  description = "Helm chart name for Spark Operator"
  type        = string
  default     = "spark-operator"
}

variable "chart_repository" {
  description = "Helm repository containing the Spark Operator chart"
  type        = string
  default     = "https://kubeflow.github.io/spark-operator"
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

variable "image_tag" {
  description = "Image tag for the Spark Operator controller (optional)"
  type        = string
  default     = null
}

variable "webhook_enabled" {
  description = "Whether to enable the Spark Operator admission webhook"
  type        = bool
  default     = false
}

variable "additional_values" {
  description = "Arbitrary values to merge into the chart configuration"
  type        = map(any)
  default     = {}
}
