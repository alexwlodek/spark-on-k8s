locals {
  name_prefix = "${var.env}-spark"
  common_tags = {
    Environment = var.env
    Project     = "spark-on-eks"
    ManagedBy   = "terraform"
  }
}

module "network" {
  source = "./modules/network"

  vpc_cidr = var.vpc_cidr
  azs      = var.azs

  tags = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  worker_instance_type = var.worker_instance_type
  worker_min_size      = var.worker_min_size
  worker_max_size      = var.worker_max_size
  worker_desired_size  = var.worker_desired_size

  tags = local.common_tags
}

module "storage" {
  source = "./modules/storage"

  env = var.env

  bucket_name               = var.results_bucket_name
  enable_versioning         = var.results_bucket_enable_versioning
  lifecycle_expiration_days = var.results_bucket_lifecycle_days

  tags = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  role_name           = "${local.name_prefix}-spark-irsa"
  oidc_provider_arn   = module.eks.oidc_provider_arn
  oidc_provider_url   = module.eks.cluster_oidc_issuer_url
  k8s_namespace       = var.spark_namespace
  k8s_service_account = var.spark_service_account_name
  results_bucket_arn  = module.storage.results_bucket_arn
  eks_cluster_arn     = module.eks.cluster_arn
  tags                = local.common_tags
}





module "k8s_spark" {
  source = "./modules/k8s_spark"

  spark_namespace_name     = "spark"
  spark_irsa_role_arn      = module.iam.spark_irsa_role_arn
  spark_operator_namespace = "spark-operator"
  spark_operator_sa_name   = "spark-operator-controller"

  depends_on = [module.eks]
}

module "ci_jenkins" {
  source = "./modules/ci_jenkins"

  jenkins_ci_role_arn = module.iam.jenkins_ci_role_arn

  # Namespace i nazwa release'u – możesz zmienić, jeśli chcesz
  namespace    = "ci"
  release_name = "jenkins"

  # Tymczasowe hasło – później przeniesiemy do SSM/Secrets
  admin_username = "admin"
  admin_password = "admin123!"

  # Na początek bez dysku trwałego, żeby było prościej
  enable_persistence = true

  # Zapewniamy, że EKS i IAM są gotowe przed Jenkins
  depends_on = [
    module.eks,
    module.iam
  ]
}


module "spark_helm" {
  source = "./modules/spark_helm"

  release_name         = "spark-operator"
  namespace            = "spark-operator"
  spark_job_namespaces = [module.k8s_spark.namespace]

  depends_on = [
    module.eks,
    module.k8s_spark
  ]
}





# Przyszłość: Spark Operator via Helm + Spark jobs
# module "spark_helm" { ... }
# module "spark_job"  { ... }
