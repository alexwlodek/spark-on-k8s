variable "namespace" {
  description = "Namespace for Jenkins"
  type        = string
  default     = "ci"
}

variable "release_name" {
  description = "Helm release name for Jenkins"
  type        = string
  default     = "jenkins"
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

variable "enable_persistence" {
  description = "Enable Jenkins persistence (PVC)"
  type        = bool
  default     = false
}

variable "github_token" {
  type      = string
  sensitive = true
}