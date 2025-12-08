module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  control_plane_subnet_ids = var.private_subnet_ids

  enable_irsa = true

  cluster_endpoint_public_access = true

  # Prosta, jedna Managed Node Group
  eks_managed_node_group_defaults = {
    ami_type       = "AL2023_x86_64_STANDARD"
    instance_types = [var.worker_instance_type]
  }

  eks_managed_node_groups = {
    default = {
      min_size     = var.worker_min_size
      max_size     = var.worker_max_size
      desired_size = var.worker_desired_size

      tags = {
        Name = "${var.cluster_name}-default-ng"
      }
    }
  }

  # EKS Cluster Access Management
  authentication_mode                     = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true


  tags = var.tags
}
