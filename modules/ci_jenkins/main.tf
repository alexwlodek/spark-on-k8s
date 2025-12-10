resource "kubernetes_namespace" "ci" {
  metadata {
    name = var.namespace
  }
}

locals {
  controller_env = concat([
    {
      name  = "GITHUB_TOKEN"
      value = var.github_token
    },
  ], var.extra_controller_env)

  controller_block = {
    admin = {
      username     = var.jenkins_user
      password     = var.jenkins_password
      createSecret = true
    }

    serviceType  = var.service_type
    numExecutors = var.controller_num_executors
    resources    = var.controller_resources
    env          = local.controller_env
  }

  controller_values = var.controller_image_tag != null ? merge(local.controller_block, {
    image = { tag = var.controller_image_tag }
  }) : local.controller_block

  persistence_block = var.enable_persistence ? merge({
    enabled = true
  }, var.persistence_storage_class != null ? {
    storageClass = var.persistence_storage_class
  } : {}) : {
    enabled = false
  }

  base_values = {
    controller = local.controller_values
    serviceAccount = {
      create                       = true
      name                         = var.release_name # Upewniamy się, że nazwa SA jest spójna
      automountServiceAccountToken = true
      annotations = merge({
        "eks.amazonaws.com/role-arn" = var.jenkins_ci_role_arn
      }, var.service_account_annotations)
    }
    persistence = local.persistence_block
  }

  merged_values = merge(local.base_values, var.values_override)
}

resource "helm_release" "jenkins" {
  name       = var.release_name
  namespace  = kubernetes_namespace.ci.metadata[0].name
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_version

  values = [
    templatefile("${path.module}/jenkins-values.tftpl", {
      namespace    = kubernetes_namespace.ci.metadata[0].name
      release_name = var.release_name
    }),

    yamlencode(local.merged_values)
  ]

  depends_on = [
    kubernetes_namespace.ci,
  ]
}

resource "kubernetes_role" "jenkins_spark_role" {
  metadata {
    name      = "${var.release_name}-spark-role"
    namespace = var.spark_namespace
  }
  rule {
    api_groups = ["sparkoperator.k8s.io"]
    resources  = ["sparkapplications", "sparkapplications/status"]
    verbs      = ["create", "get", "list", "watch", "delete", "update", "patch"]
  }
}

resource "kubernetes_role_binding" "jenkins_spark_rbac" {
  metadata {
    name      = "${var.release_name}-spark-rb"
    namespace = var.spark_namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.jenkins_spark_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.release_name # To musi pasować do `serviceAccount.name` w Helm
    namespace = kubernetes_namespace.ci.metadata[0].name
  }
  depends_on = [
    kubernetes_namespace.ci,
    kubernetes_role.jenkins_spark_role,
    helm_release.jenkins
  ]
}