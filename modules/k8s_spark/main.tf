resource "kubernetes_namespace" "spark" {
  metadata {
    name = var.spark_namespace_name
  }
}

resource "kubernetes_service_account" "spark_sa" {
  metadata {
    name      = "spark-sa"
    namespace = kubernetes_namespace.spark.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = var.spark_irsa_role_arn
    }
  }

  depends_on = [
    kubernetes_namespace.spark
  ]
}

resource "kubernetes_role" "spark_sa_role" {
  metadata {
    name      = "spark-sa-role"
    namespace = kubernetes_namespace.spark.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = [
      "pods",
      "pods/log",
      "services",
      "configmaps",
      "persistentvolumeclaims"
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "update",
      "patch",
      "delete",
      "deletecollection"
    ]
  }

  depends_on = [
    kubernetes_namespace.spark
  ]
}

resource "kubernetes_role_binding" "spark_sa_binding" {
  metadata {
    name      = "spark-sa-binding"
    namespace = kubernetes_namespace.spark.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.spark_sa_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.spark_sa.metadata[0].name
    namespace = kubernetes_namespace.spark.metadata[0].name
  }

  depends_on = [
    kubernetes_role.spark_sa_role,
    kubernetes_service_account.spark_sa
  ]
}

# RBAC dla Spark Operatora w namespace spark – pozwala mu działać na pods/configmaps
resource "kubernetes_role" "spark_operator_controller_role" {
  metadata {
    name      = "spark-operator-controller-spark-role"
    namespace = kubernetes_namespace.spark.metadata[0].name
  }

  # Podstawowe zasoby w ns spark
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "configmaps", "services"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  # CRD-y sparkoperatora w ns spark
  rule {
    api_groups = ["sparkoperator.k8s.io"]
    resources  = ["sparkapplications", "scheduledsparkapplications", "sparkconnects"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "spark_operator_controller_binding" {
  metadata {
    name      = "spark-operator-controller-spark-binding"
    namespace = kubernetes_namespace.spark.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.spark_operator_controller_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.spark_operator_sa_name
    namespace = var.spark_operator_namespace
  }
}