
# EKS Cluster Configuration
module "eks" {
  source = "${local.module_source}eks"

  # Cluster Configuration
  cluster_name       = var.eks_cluster_name
  kubernetes_version = var.eks_kubernetes_version

  # Network Configuration
  vpc_id              = var.vpc_id
  subnet_ids          = var.eks_subnet_ids
  private_subnet_ids  = var.eks_subnet_ids

  # API Server Access Configuration
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"]

  # Logging Configuration
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Node Group Configuration
  capacity_type    = var.eks_capacity_type
  instance_types   = var.eks_instance_types
  ami_type         = "AL2_x86_64"
  disk_size        = var.eks_disk_size

  # Scaling Configuration
  desired_size = var.eks_desired_size
  max_size     = var.eks_max_size
  min_size     = var.eks_min_size

  # Update Configuration
  max_unavailable = 1

  # Mandatory Organizational Tags
  contact_group                 = var.contact_group
  contact_name                  = var.contact_name
  cost_bucket                   = var.cost_bucket
  data_owner                    = var.data_owner
  display_name                  = var.display_name
  environment                   = var.environment
  has_public_ip                 = var.has_public_ip
  has_unisys_network_connection = var.has_unisys_network_connection
  service_line                  = var.service_line

  # Common tags
  common_tags = {
    Project     = var.project_name
    ManagedBy   = "terraform"
    Component   = "eks-cluster"
  }
}

# Outputs for EKS Cluster
output "eks_cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks.cluster_version
}

output "eks_node_group_arn" {
  description = "EKS node group ARN"
  value       = module.eks.node_group_arn
}

output "eks_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  value       = module.eks.oidc_issuer_url
}
