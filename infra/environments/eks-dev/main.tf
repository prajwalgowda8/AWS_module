
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Local values for environment-specific configuration
locals {
  environment = "dev"
  project     = "sc-eks-demo"
  
  # Manually created VPC and subnet IDs (replace with your actual IDs)
  vpc_id = "vpc-0123456789abcdef0"
  
  # Public subnets for EKS cluster endpoint access
  public_subnet_ids = [
    "subnet-0123456789abcdef1",
    "subnet-0123456789abcdef2"
  ]
  
  # Private subnets for EKS worker nodes
  private_subnet_ids = [
    "subnet-0123456789abcdef3",
    "subnet-0123456789abcdef4"
  ]
  
  # All subnets (public + private) for EKS cluster
  all_subnet_ids = concat(local.public_subnet_ids, local.private_subnet_ids)
  
  # Common tags for all resources
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    CreatedDate = "2025-01-02"
  }
}

# EKS Cluster Module
module "eks_cluster" {
  source = "../../modules/eks"
  
  # Cluster configuration
  cluster_name       = "sc-eks-demo"
  kubernetes_version = "1.28"
  
  # Network configuration (manually created VPC/subnets)
  vpc_id             = local.vpc_id
  subnet_ids         = local.all_subnet_ids
  private_subnet_ids = local.private_subnet_ids
  
  # Node group configuration
  instance_types = ["m5.xlarge"]
  desired_size   = 3
  min_size       = 3
  max_size       = 5
  disk_size      = 50
  capacity_type  = "ON_DEMAND"
  
  # API endpoint configuration
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"]
  
  # Logging configuration
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  # Mandatory tags
  common_tags                    = local.common_tags
  contact_group                  = "DevOps Team"
  contact_name                   = "John Doe"
  cost_bucket                    = "development"
  data_owner                     = "Engineering Team"
  display_name                   = "SC EKS Demo Development"
  environment                    = local.environment
  has_public_ip                  = "true"
  has_unisys_network_connection  = "false"
  service_line                   = "Platform Services"
}

# Output cluster information for kubectl configuration
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_cluster.cluster_name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks_cluster.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for cluster"
  value       = module.eks_cluster.cluster_certificate_authority_data
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for the cluster"
  value       = module.eks_cluster.oidc_issuer_url
}

output "node_group_arn" {
  description = "EKS node group ARN"
  value       = module.eks_cluster.node_group_arn
}

output "cluster_security_group_id" {
  description = "Security group ID for the cluster"
  value       = module.eks_cluster.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID for the nodes"
  value       = module.eks_cluster.node_security_group_id
}
