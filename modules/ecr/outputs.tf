output "repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.this.name
}

output "repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.this.arn
}

output "repository_url" {
  description = "Full ECR repository URL (ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/NAME)"
  value       = aws_ecr_repository.this.repository_url
}
