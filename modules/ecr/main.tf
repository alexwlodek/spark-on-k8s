locals {
  ecr_encryption_configuration = var.encryption_type == "KMS" ? {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn != "" ? var.kms_key_arn : null
  } : {
    encryption_type = "AES256"
    kms_key         = null
  }
}

resource "aws_ecr_repository" "this" {
  name = var.repository_name

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = local.ecr_encryption_configuration.encryption_type


    kms_key = local.ecr_encryption_configuration.kms_key
  }

  force_delete = true
 
  tags = var.tags
}


resource "aws_ecr_lifecycle_policy" "this" {
  count      = var.lifecycle_policy_enabled ? 1 : 0
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than ${var.lifecycle_policy_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.lifecycle_policy_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
