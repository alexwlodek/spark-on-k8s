variable "aws_region" {
  description = "AWS region where all resources will be created."
  type        = string
  default     = "eu-central-1"
}

variable "env" {
  description = "Environment name used for tagging and naming."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of Availability Zones to use for subnets."
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "spark-eks-dev"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS."
  type        = string
  default     = "1.30"
}

variable "worker_instance_type" {
  description = "Instance type for EKS managed node group."
  type        = string
  default     = "t3.medium"
}

variable "worker_min_size" {
  description = "Min size of the worker node group."
  type        = number
  default     = 1
}

variable "worker_max_size" {
  description = "Max size of the worker node group."
  type        = number
  default     = 1
}

variable "worker_desired_size" {
  description = "Desired size of the worker node group."
  type        = number
  default     = 1
}

variable "spark_namespace" {
  description = "Kubernetes namespace where Spark jobs will run."
  type        = string
  default     = "spark"
}

variable "spark_service_account_name" {
  description = "Kubernetes service account name used by Spark for IRSA."
  type        = string
  default     = "spark-sa"
}

variable "spark_operator_namespace" {
  description = "Namespace where the Spark Operator components are installed."
  type        = string
  default     = "spark-operator"
}

variable "spark_operator_service_account_name" {
  description = "Service account name used by the Spark Operator controller."
  type        = string
  default     = "spark-operator-controller"
}



variable "results_bucket_name" {
  description = "Name of the S3 bucket for Spark results. Must be globally unique."
  type        = string
  default     = ""
}

variable "results_bucket_enable_versioning" {
  description = "Enable versioning on the results S3 bucket."
  type        = bool
  default     = false
}

variable "results_bucket_lifecycle_days" {
  description = "Number of days after which objects in results bucket are expired."
  type        = number
  default     = 30
}

variable "ecr_repository_name" {
  description = "Optional override for the Spark jobs ECR repository name (without account/region prefix)."
  type        = string
  default     = null
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push for the Spark jobs ECR repository."
  type        = bool
  default     = true
}

variable "ecr_encryption_type" {
  description = "ECR encryption type for Spark images: KMS or AES256."
  type        = string
  default     = "KMS"
}

variable "ecr_kms_key_arn" {
  description = "Optional KMS key ARN for ECR encryption. Required if encryption type is KMS and a customer-managed key is desired."
  type        = string
  default     = ""
}

variable "ecr_lifecycle_policy_enabled" {
  description = "Whether to attach a lifecycle policy to the Spark jobs ECR repository."
  type        = bool
  default     = true
}

variable "ecr_lifecycle_policy_days" {
  description = "Number of days to retain untagged images in the Spark jobs ECR repository."
  type        = number
  default     = 30
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "jenkins_user" {
  description = "Jenkins Admin username"
  type = string
}

variable "jenkins_password" {
  description = "Jenkins Admin password"
  type = string
}

variable "jenkins_namespace" {
  description = "Kubernetes namespace for the Jenkins deployment."
  type        = string
  default     = "ci"
}

variable "jenkins_release_name" {
  description = "Helm release name used for the Jenkins chart."
  type        = string
  default     = "jenkins"
}

variable "jenkins_enable_persistence" {
  description = "Toggle persistence for the Jenkins controller."
  type        = bool
  default     = false
}
