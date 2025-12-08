output "results_bucket_name" {
  description = "Name of the S3 bucket for Spark results."
  value       = aws_s3_bucket.results.bucket
}

output "results_bucket_arn" {
  description = "ARN of the S3 bucket for Spark results."
  value       = aws_s3_bucket.results.arn
}
