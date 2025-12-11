resource "kubernetes_namespace" "ci" {
  metadata {
    name = var.namespace
  }
}

locals {
  persistence_config = merge(
    {
      enabled = var.enable_persistence
      size    = var.persistence_size
    },
    var.persistence_storage_class != null ? { storageClass = var.persistence_storage_class } : {}
  )
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
      namespace          = kubernetes_namespace.ci.metadata[0].name
      release_name       = var.release_name
      install_plugins    = var.jenkins_plugins
      container_cap      = var.agent_container_cap
      jnlp_image         = var.jnlp_image
      kaniko_image       = var.kaniko_image
      kubectl_image      = var.kubectl_image
      kaniko_resources   = var.kaniko_resources
      kubectl_resources  = var.kubectl_resources
      pipeline_repo_url  = var.pipeline_repo_url
      pipeline_branch    = var.pipeline_branch
      pipeline_script_path = var.pipeline_script_path
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
        

        resources = var.controller_resources

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
        enabled      = local.persistence_config.enabled
        size         = local.persistence_config.size
        storageClass = lookup(local.persistence_config, "storageClass", null)
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