variable "role_name" {
  description = "Name of the IAM role used by Spark via IRSA."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider."
  type        = string
}

variable "oidc_provider_url" {
  description = "Issuer URL of the EKS OIDC provider."
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace where Spark runs."
  type        = string
}

variable "k8s_service_account" {
  description = "Kubernetes service account name used by Spark."
  type        = string
}

variable "results_bucket_arn" {
  description = "ARN of the S3 bucket for Spark results."
  type        = string
}

variable "eks_cluster_arn" {
  description = "ARN of the EKS cluster (for Jenkins CI role)."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Name of Jenkins environment"
  type        = string
  default     = "dev"
}
