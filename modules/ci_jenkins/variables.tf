variable "namespace" {
  description = "Namespace for Jenkins"
  type        = string
  default     = "ci"
}

variable "spark_namespace" {
  description = "Namespace where Spark applications are deployed"
  type        = string
  default     = "spark"
}

variable "release_name" {
  description = "Helm release name for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_repository" {
  description = "Helm chart repository for Jenkins"
  type        = string
  default     = "https://charts.jenkins.io"
}

variable "chart_name" {
  description = "Helm chart name for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Helm chart version for Jenkins"
  type        = string
  default     = null
}

variable "jenkins_ci_role_arn" {
  description = "IAM role ARN used by Jenkins via IRSA"
  type        = string
}

variable "service_type" {
  description = "Kubernetes Service type for Jenkins controller"
  type        = string
  default     = "LoadBalancer"
}

variable "controller_image_tag" {
  description = "Override the Jenkins controller image tag"
  type        = string
  default     = null
}

variable "controller_num_executors" {
  description = "Number of executors for Jenkins controller"
  type        = number
  default     = 0
}

variable "controller_resources" {
  description = "Resource requests and limits for Jenkins controller"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "200m"
      memory = "512Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "1Gi"
    }
  }
}

variable "extra_controller_env" {
  description = "Additional environment variables for Jenkins controller"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "jenkins_user" {
  description = "Initial Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "jenkins_password" {
  description = "Initial Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "service_account_annotations" {
  description = "Extra annotations for the Jenkins service account"
  type        = map(string)
  default     = {}
}

variable "enable_persistence" {
  description = "Enable Jenkins persistence (PVC)"
  type        = bool
  default     = false
}

variable "persistence_storage_class" {
  description = "StorageClass used when persistence is enabled"
  type        = string
  default     = null
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "values_override" {
  description = "Additional Helm values to merge into the Jenkins chart"
  type        = map(any)
  default     = {}
}