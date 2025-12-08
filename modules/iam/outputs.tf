output "spark_irsa_role_arn" {
  description = "IAM role ARN for Spark IRSA."
  value       = aws_iam_role.spark_irsa_role.arn
}
