output "karpenter_controller_role_arn" {
  description = "ARN of the Karpenter controller IAM role"
  value       = aws_iam_role.karpenter_controller.arn
}

output "karpenter_node_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  value       = aws_iam_role.karpenter_node.arn
}

output "karpenter_queue_name" {
  description = "Name of the Karpenter SQS queue"
  value       = aws_sqs_queue.karpenter.name
}

output "karpenter_security_group_id" {
  description = "ID of the Karpenter node security group"
  value       = aws_security_group.karpenter_node.id
}

output "karpenter_namespace" {
  description = "Karpenter namespace"
  value       = kubernetes_namespace.karpenter.metadata[0].name
}