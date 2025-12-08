resource "kubernetes_namespace" "ci" {
  metadata {
    name = var.namespace
  }
}

# SA z IRSA dla Jenkinsa
resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.ci.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = var.jenkins_ci_role_arn
    }
  }
}

resource "helm_release" "jenkins" {
  name       = var.release_name
  namespace  = kubernetes_namespace.ci.metadata[0].name
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"

  # Nie tworzymy własnego SA – używamy tego z IRSA
  values = [
    yamlencode({
      controller = {
        adminUser     = var.admin_username
        adminPassword = var.admin_password

        serviceType = var.service_type

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

        serviceAccount = {
          create = false
          name   = kubernetes_service_account.jenkins.metadata[0].name
        }
      }

      persistence = {
        enabled = var.enable_persistence
      }
    })
  ]

  depends_on = [kubernetes_service_account.jenkins]
}
