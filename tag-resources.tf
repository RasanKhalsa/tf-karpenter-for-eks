# Tag existing subnets for Karpenter discovery
resource "aws_ec2_tag" "subnet_tags" {
  for_each    = toset(data.aws_subnets.cluster_subnets.ids)
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Tag the cluster security group for Karpenter discovery
resource "aws_ec2_tag" "cluster_sg_tag" {
  resource_id = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Tag the Karpenter node security group for discovery
resource "aws_ec2_tag" "karpenter_sg_tag" {
  resource_id = aws_security_group.karpenter_node.id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}