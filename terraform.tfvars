aws_region             = "us-east-1"
cluster_name           = "karpenter-eks-cluster"
karpenter_version      = "1.0.8"
node_instance_types    = ["t3.medium", "t3.large", "t3.xlarge"]
node_capacity_type     = ["on-demand"]
create_test_deployment = false
nodepool_cpu_limit     = 1000
