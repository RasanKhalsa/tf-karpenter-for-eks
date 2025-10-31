variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "karpenter_version" {
  description = "Karpenter version"
  type        = string
  default     = "1.0.8"
}

variable "node_instance_types" {
  description = "Instance types for Karpenter nodes"
  type        = list(string)
  default     = ["t3.medium", "t3.large", "t3.xlarge"]
}

variable "node_capacity_type" {
  description = "Capacity type for nodes (spot, on-demand)"
  type        = list(string)
  default     = ["on-demand"]  # Changed to on-demand only for reliability
}

variable "create_test_deployment" {
  description = "Whether to create a test deployment to trigger Karpenter"
  type        = bool
  default     = true
}

variable "nodepool_cpu_limit" {
  description = "CPU limit for Karpenter NodePool"
  type        = number
  default     = 1000
}