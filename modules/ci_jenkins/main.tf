resource "kubernetes_namespace" "ci" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "jenkins" {
  name      = var.release_name
  namespace = kubernetes_namespace.ci.metadata[0].name

  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  # optionalnie: version = "5.8.110"

  values = [
    file("${path.module}/values.yaml"),

    yamlencode({
      controller = {
        admin = {
          username     = var.admin_username
          password     = var.admin_password
          createSecret = true
        }

        serviceType  = var.service_type
        numExecutors = 0

        resources = {
          requests = {
            cpu    = "200m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "1Gi"
          }
        }
      }

      # <<< KLUCZOWA CZĘŚĆ >>>
      serviceAccount = {
        # domyślnie i tak jest true, ale jawnie ustawmy
        create                        = true
        automountServiceAccountToken  = true
        annotations = {
          "eks.amazonaws.com/role-arn" = var.jenkins_ci_role_arn
        }
      }

      persistence = {
        enabled = var.enable_persistence
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.ci,
  ]
}


resource "kubernetes_role" "jenkins_spark_role" {
  metadata {
    name      = "${var.release_name}-spark-role"
    namespace = "spark"
  }

  rule {
    api_groups = ["sparkoperator.k8s.io"]
    resources  = ["sparkapplications", "sparkapplications/status"]
    verbs      = ["create", "get", "list", "watch", "delete", "update", "patch"]
  }

    depends_on = [
    kubernetes_namespace.ci,
  ]
}

resource "kubernetes_role_binding" "jenkins_spark_rbac" {
  metadata {
    name      = "${var.release_name}-spark-rb"
    namespace = "spark"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.jenkins_spark_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.release_name
    namespace = kubernetes_namespace.ci.metadata[0].name
  }


    depends_on = [
    kubernetes_namespace.ci,
    kubernetes_role.jenkins_spark_role,
  ]
}