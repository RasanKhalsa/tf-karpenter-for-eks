# Get EKS cluster information
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# Get current AWS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get VPC information from EKS cluster
data "aws_vpc" "cluster_vpc" {
  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
}

# Get subnets from EKS cluster
data "aws_subnets" "cluster_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.cluster_vpc.id]
  }
}

# Get the latest EKS optimized AMI
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${data.aws_eks_cluster.cluster.version}/amazon-linux-2/recommended/release_version"
}