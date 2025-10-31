# Karpenter installation using Helm and necessary Kubernetes resources
# Karpenter namespace
resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

# Karpenter service account
resource "kubernetes_service_account" "karpenter" {
  metadata {
    name      = "karpenter"
    namespace = kubernetes_namespace.karpenter.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter_controller.arn
    }
  }
}

# Install Karpenter using Helm
resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version
  namespace  = kubernetes_namespace.karpenter.metadata[0].name

  values = [
    yamlencode({
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.karpenter.metadata[0].name
      }
      settings = {
        clusterName       = var.cluster_name
        interruptionQueue = aws_sqs_queue.karpenter.name
      }
      # Single replica for single node setup
      replicas = 1
      controller = {
        resources = {
          requests = {
            cpu    = "200m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "400m"
            memory = "1Gi"
          }
        }
      }
      # Disable anti-affinity for single node setup
      affinity = {}

    })
  ]

  depends_on = [
    kubernetes_service_account.karpenter,
    aws_iam_role_policy_attachment.karpenter_controller
  ]
}

# Wait for Karpenter to be ready
resource "time_sleep" "wait_for_karpenter" {
  depends_on      = [helm_release.karpenter]
  create_duration = "60s"
}
