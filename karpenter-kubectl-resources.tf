# Karpenter resources using kubectl provider
# This replaces the null_resource pattern with native kubectl provider resources
# 
# Configuration Notes:
# - Uses on-demand instances only for reliability (spot instances can cause bootstrap issues)
# - Automatically applies workload-type=karpenter-managed label via userData script
# - NodePool template labels are for scheduling, actual node labels come from userData

# EC2NodeClass resource using kubectl provider
resource "kubectl_manifest" "ec2nodeclass_default" {
  depends_on = [
    helm_release.karpenter,
    time_sleep.wait_for_karpenter
  ]

  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      amiFamily = "AL2"
      amiSelectorTerms = [
        {
          name = "amazon-eks-node-1.32-*"
        }
      ]
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      role = aws_iam_instance_profile.karpenter_node.name      
      tags = {
        "karpenter.sh/cluster" = var.cluster_name
        "Name"                 = "${var.cluster_name}-karpenter-node"
      }
    }
  })

  # Wait for the resource to be ready
  wait_for_rollout = true

  # Force replacement if configuration changes
  force_new = true
}

# NodePool resource using kubectl provider
resource "kubectl_manifest" "nodepool_default" {
  depends_on = [
    kubectl_manifest.ec2nodeclass_default
  ]

  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "default"
    }
    spec = {
      template = {
        metadata = {
          labels = {
            "workload-type" = "karpenter-managed"
          }
        }
        spec = {
          requirements = [
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "kubernetes.io/os"
              operator = "In"
              values   = ["linux"]
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["on-demand"] # Hardcoded to on-demand for reliability
            },
            {
              key      = "node.kubernetes.io/instance-type"
              operator = "In"
              values   = var.node_instance_types
            }
          ]
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "default"
          }
          expireAfter = "30m"
          taints      = []
        }
      }
      limits = {
        cpu = var.nodepool_cpu_limit
      }
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "30s"
      }
    }
  })

  # Wait for the resource to be ready
  wait_for_rollout = true

  # Force replacement if configuration changes
  force_new = true
}

# Test deployments removed - use manual YAML files for testing
