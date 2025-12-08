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

  values = [
    yamlencode({
      controller = {
        admin = {
          username     = var.admin_username
          password     = var.admin_password
          createSecret = true
        }

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

        # <<< KLUCZOWA CZĘŚĆ: SA + IRSA >>>
        serviceAccount = {
          create = true
          name   = "jenkins"
          annotations = {
            "eks.amazonaws.com/role-arn" = var.jenkins_ci_role_arn
          }
        }
      }

      persistence = {
        enabled = var.enable_persistence
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.ci
  ]
}

