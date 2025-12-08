output "vpc_id" {
  description = "ID of the created VPC."
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of private subnets."
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = module.network.public_subnet_ids
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca_certificate" {
  description = "EKS cluster CA certificate (base64)."
  value       = module.eks.cluster_ca_certificate
}

output "eks_oidc_provider_arn" {
  description = "ARN of the OIDC provider associated with the EKS cluster."
  value       = module.eks.oidc_provider_arn
}

output "spark_irsa_role_arn" {
  description = "IAM role ARN used by Spark via IRSA."
  value       = module.iam.spark_irsa_role_arn
}

output "results_bucket_name" {
  description = "Name of the S3 bucket for Spark results."
  value       = module.storage.results_bucket_name
}

output "results_bucket_arn" {
  description = "ARN of the S3 bucket for Spark results."
  value       = module.storage.results_bucket_arn
}
