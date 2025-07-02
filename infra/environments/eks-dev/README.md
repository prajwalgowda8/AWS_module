
# EKS Development Environment

This environment deploys the sc-eks-demo EKS cluster using manually created VPC and subnet resources.

## Prerequisites

Before deploying this environment, ensure you have:

1. **Manually Created VPC and Subnets**: Update the VPC and subnet IDs in `main.tf`:
   ```hcl
   vpc_id = "vpc-0123456789abcdef0"  # Replace with your VPC ID
   
   public_subnet_ids = [
     "subnet-0123456789abcdef1",     # Replace with your public subnet IDs
     "subnet-0123456789abcdef2"
   ]
   
   private_subnet_ids = [
     "subnet-0123456789abcdef3",     # Replace with your private subnet IDs
     "subnet-0123456789abcdef4"
   ]
   ```

2. **AWS CLI configured** with appropriate permissions
3. **Terraform installed** (version >= 1.0)

## Cluster Configuration

- **Cluster Name**: sc-eks-demo
- **Kubernetes Version**: 1.28
- **Node Group**: 3 x m5.xlarge instances
- **Capacity Type**: ON_DEMAND
- **Disk Size**: 50 GiB per node

## Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Post-Deployment

After successful deployment, configure kubectl to access your cluster:

```bash
aws eks update-kubeconfig --region us-east-1 --name sc-eks-demo
```

Verify cluster access:
```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## Mandatory Tags

All resources are tagged with the following mandatory tags:
- `contactGroup`: DevOps Team
- `contactName`: John Doe
- `costBucket`: development
- `dataOwner`: Engineering Team
- `displayName`: SC EKS Demo Development
- `environment`: dev
- `hasPublicIP`: true
- `hasUnisysNetworkConnection`: false
- `serviceLine`: Platform Services

## Cleanup

To destroy the environment:
```bash
terraform destroy
```

**Note**: Ensure all workloads are removed from the cluster before destroying to avoid issues.
