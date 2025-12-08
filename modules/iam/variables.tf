variable "role_name" {
  description = "Name of the IAM role for Spark IRSA."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider."
  type        = string
}

variable "oidc_issuer_url" {
  description = "Issuer URL of the EKS OIDC provider."
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace where the service account exists."
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

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
