# Karpenter Setup for EKS

This Terraform configuration sets up Karpenter for automatic node provisioning in your EKS cluster.

## Prerequisites

1. EKS cluster must be running and accessible
2. kubectl configured to access the cluster
3. Terraform >= 1.0
4. AWS CLI configured

## What This Creates

- **IAM Roles**: Controller and node roles with required permissions
- **Security Groups**: For Karpenter nodes
- **Karpenter Installation**: Via Helm chart
- **NodePool & EC2NodeClass**: Karpenter v1beta1 resources
- **Test Deployment**: Optional nginx deployment to trigger node creation

## Usage

1. **Copy and customize variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Initialize and apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Verify Karpenter is running:**
   ```bash
   kubectl get pods -n karpenter
   kubectl get nodepool
   kubectl get ec2nodeclass
   ```
### Impottent: Update aws-auth ConfigMap
Added the Karpenter node IAM role to the `aws-auth` ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::<AWS_Account>:role/karpenter-eks-cluster-managed-node-group
      groups:
      - system:bootstrappers
      - system:nodes
      username: system:node:{{EC2PrivateDNSName}}
    - rolearn: arn:aws:iam::<AWS_Account>:role/KarpenterNodeInstanceProfile-karpenter-eks-cluster
      groups:
      - system:bootstrappers
      - system:nodes
      username: system:node:{{EC2PrivateDNSName}}
```

### Step 3: Apply the Configuration
```bash
kubectl apply -f aws-auth-patch.yaml
```

## Validation

### Test Deployment
Use `test-deployment-karpenter.yaml` to validate the configuration:

```bash
kubectl apply -f test-deployment-karpenter.yaml
kubectl get pods -l app=karpenter-test -o wide
```

### Expected Results
1. Karpenter provisions new on-demand nodes
2. Nodes automatically have `workload-type=karpenter-managed` label
3. Pods schedule successfully on Karpenter nodes
4. No manual labeling required


```

## Monitoring

Check Karpenter logs:
```bash
kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter
```

View node provisioning events:
```bash
kubectl get events --sort-by='.lastTimestamp' | grep karpenter
```

## Cleanup

To remove everything:
```bash
terraform destroy
```

Note: Karpenter will automatically terminate any nodes it created when the NodePool is deleted.