locals {
  final_bucket_name = (
    length(var.bucket_name) > 0
    ? var.bucket_name
    : "spark-portfolio-results-${var.env}"
  )
}

resource "aws_s3_bucket" "results" {
  bucket = local.final_bucket_name

  tags = merge(
    var.tags,
    { Name = local.final_bucket_name }
  )
}

resource "aws_s3_bucket_versioning" "results" {
  bucket = aws_s3_bucket.results.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "results" {
  bucket = aws_s3_bucket.results.id

  rule {
    id     = "expire-objects"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.lifecycle_expiration_days
    }
  }
}
