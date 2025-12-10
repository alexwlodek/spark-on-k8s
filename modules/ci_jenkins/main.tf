resource "kubernetes_namespace" "ci" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "jenkins" {
  name       = var.release_name
  namespace  = kubernetes_namespace.ci.metadata[0].name
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  # version    = "5.8.110" # Warto przypiąć wersję dla stabilności

  values = [
    # 1. Wczytujemy szablon values i podstawiamy zmienne z Terraform
    templatefile("${path.module}/jenkins-values.tftpl", {
      namespace    = kubernetes_namespace.ci.metadata[0].name
      release_name = var.release_name
    }),

    # 2. Nadpisujemy specyficzną konfigurację (Admin, Zasoby, ServiceAccount, ENV)
    yamlencode({
      controller = {
        admin = {
          username     = var.jenkins_user
          password     = var.jenkins_password
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

        # Wstrzyknięcie tokena jako zmienna środowiskowa do Controllera
        # JCasC (z pliku powyżej) odczyta to jako ${GITHUB_TOKEN}
        env = [
          {
            name  = "GITHUB_TOKEN"
            value = var.github_token
          }
        ]
      }

      serviceAccount = {
        create                       = true
        name                         = var.release_name # Upewniamy się, że nazwa SA jest spójna
        automountServiceAccountToken = true
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

# --- RBAC dla Sparka (Bez zmian, wygląda poprawnie) ---
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
    name      = var.release_name # To musi pasować do `serviceAccount.name` w Helm
    namespace = kubernetes_namespace.ci.metadata[0].name
  }
  depends_on = [
    kubernetes_namespace.ci,
    kubernetes_role.jenkins_spark_role,
    helm_release.jenkins
  ]
}