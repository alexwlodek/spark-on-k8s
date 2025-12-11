locals {
  name_prefix = "${var.env}-spark"
  common_tags = {
    Environment = var.env
    Project     = "spark-on-eks"
    ManagedBy   = "terraform"
  }
  ecr_repository_name = coalesce(var.ecr_repository_name, "spark-on-k8s-jobs-${var.env}")
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


module "ecr" {
  source = "./modules/ecr"

  repository_name = local.ecr_repository_name

  scan_on_push     = var.ecr_scan_on_push
  encryption_type  = var.ecr_encryption_type
  kms_key_arn      = var.ecr_kms_key_arn

  lifecycle_policy_enabled = var.ecr_lifecycle_policy_enabled
  lifecycle_policy_days    = var.ecr_lifecycle_policy_days

  tags = local.common_tags
}



module "k8s_spark" {
  source = "./modules/k8s_spark"

  spark_namespace_name     = var.spark_namespace
  spark_irsa_role_arn      = module.iam.spark_irsa_role_arn
  spark_operator_namespace = var.spark_operator_namespace
  spark_operator_sa_name   = var.spark_operator_service_account_name
  

  depends_on = [module.eks]
}

module "ci_jenkins" {
  source = "./modules/jenkins_helm"

  jenkins_ci_role_arn = module.iam.jenkins_ci_role_arn

 
  namespace    = var.jenkins_namespace
  release_name = var.jenkins_release_name

 
  jenkins_user = var.jenkins_user
  jenkins_password = var.jenkins_password

  
  enable_persistence = var.jenkins_enable_persistence

  github_token = var.github_token
  
  
  depends_on = [
    module.eks,
    module.iam
  ]
}


module "spark_helm" {
  source = "./modules/spark_helm"

  spark_job_namespaces = [module.k8s_spark.namespace]

  depends_on = [
    module.eks,
    module.k8s_spark
  ]
}


