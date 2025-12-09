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
  default     = "t3.small"
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
