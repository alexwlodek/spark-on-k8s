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

variable "persistence_size" {
  description = "Size of the Jenkins PVC (used when persistence is enabled)"
  type        = string
  default     = "8Gi"
}

variable "persistence_storage_class" {
  description = "Optional storage class name for Jenkins PVC"
  type        = string
  default     = null
}

variable "jenkins_plugins" {
  description = "List of Jenkins plugins to install"
  type        = list(string)
  default = [
    "kubernetes",
    "kubernetes-credentials",
    "workflow-aggregator",
    "git",
    "git-client",
    "configuration-as-code",
    "github",
    "github-branch-source",
    "docker-workflow",
    "job-dsl",
  ]
}

variable "controller_resources" {
  description = "Resource requests and limits for the Jenkins controller"
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

variable "agent_container_cap" {
  description = "Maximum number of Kubernetes agents Jenkins is allowed to run"
  type        = number
  default     = 10
}

variable "jnlp_image" {
  description = "Container image for the JNLP inbound agent"
  type        = string
  default     = "jenkins/inbound-agent:alpine-jdk17"
}

variable "kaniko_image" {
  description = "Container image for the Kaniko executor"
  type        = string
  default     = "gcr.io/kaniko-project/executor:debug"
}

variable "kaniko_resources" {
  description = "Resource requests and limits for the Kaniko container"
  type = object({
    limit_cpu        = string
    limit_memory     = string
    request_cpu      = string
    request_memory   = string
  })
  default = {
    limit_cpu      = "500m"
    limit_memory   = "1Gi"
    request_cpu    = "250m"
    request_memory = "512Mi"
  }
}

variable "kubectl_image" {
  description = "Container image for the kubectl/helm helper"
  type        = string
  default     = "dtzar/helm-kubectl:latest"
}

variable "kubectl_resources" {
  description = "Resource requests and limits for the kubectl container"
  type = object({
    limit_cpu        = string
    limit_memory     = string
    request_cpu      = string
    request_memory   = string
  })
  default = {
    limit_cpu      = "200m"
    limit_memory   = "256Mi"
    request_cpu    = "100m"
    request_memory = "128Mi"
  }
}

variable "pipeline_repo_url" {
  description = "Git repository URL for the main Jenkins pipeline"
  type        = string
  default     = "https://github.com/alexwlodek/spark-on-k8s-jobs.git"
}

variable "pipeline_branch" {
  description = "Branch selector for the main Jenkins pipeline"
  type        = string
  default     = "main"
}

variable "pipeline_script_path" {
  description = "Path to the Jenkinsfile within the pipeline repository"
  type        = string
  default     = "Jenkinsfile"
}