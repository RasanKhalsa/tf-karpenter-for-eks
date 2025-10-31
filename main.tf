

# Security group for Karpenter nodes
resource "aws_security_group" "karpenter_node" {
  name_prefix = "${var.cluster_name}-karpenter-node"
  vpc_id      = data.aws_vpc.cluster_vpc.id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "${var.cluster_name}-karpenter-node"
    "karpenter.sh/cluster"                      = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}