variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version."
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API server endpoint should be publicly accessible."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the VPC where EKS will be created."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for worker nodes and control plane."
  type        = list(string)
}

variable "worker_instance_type" {
  description = "Instance type for the managed node group."
  type        = string
}

variable "worker_min_size" {
  description = "Minimum number of nodes in the managed node group."
  type        = number
}

variable "worker_max_size" {
  description = "Maximum number of nodes in the managed node group."
  type        = number
}

variable "worker_desired_size" {
  description = "Desired number of nodes in the managed node group."
  type        = number
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
