# Document trust policy for IRSA (EKS OIDC)
data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      # issuer URL bez https://, np. oidc.eks.<region>.amazonaws.com/id/XXXX
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account}"
      ]
    }
  }
}

resource "aws_iam_role" "spark_irsa_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json

  tags = merge(
    var.tags,
    { Name = var.role_name }
  )
}

# S3 access policy (minimalne uprawnienia dla wyników Spark)
data "aws_iam_policy_document" "spark_s3_access" {
  statement {
    sid    = "SparkResultsAccess"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${var.results_bucket_arn}/*"
    ]
  }

  statement {
    sid    = "SparkResultsListBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      var.results_bucket_arn
    ]
  }
}

resource "aws_iam_policy" "spark_s3_access" {
  name        = "${var.role_name}-s3-access"
  description = "S3 access for Spark jobs via IRSA."
  policy      = data.aws_iam_policy_document.spark_s3_access.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "spark_s3_attachment" {
  role       = aws_iam_role.spark_irsa_role.name
  policy_arn = aws_iam_policy.spark_s3_access.arn
}

resource "aws_iam_role" "jenkins_ci" {
  name = "${var.environment}-spark-jenkins-ci"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # dopasuj do SA: namespace "ci", name "jenkins"
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:ci:jenkins"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "jenkins_ci" {
  name        = "${var.environment}-spark-jenkins-ci"
  description = "CI role for Jenkins to build images and deploy SparkApplications"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECR – push/pull
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      },
      # EKS – pobranie kubeconfiga
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = module.eks.cluster_arn
      },
      # (opcjonalnie) S3 do odczytu/zapisu artefaktów
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          module.storage.results_bucket_arn,
          "${module.storage.results_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ci_attach" {
  role       = aws_iam_role.jenkins_ci.name
  policy_arn = aws_iam_policy.jenkins_ci.arn
}

output "jenkins_ci_role_arn" {
  value       = aws_iam_role.jenkins_ci.arn
  description = "IAM role used by Jenkins via IRSA"
}
