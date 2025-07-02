
# Common Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "my-project"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "my-project"
    ManagedBy   = "terraform"
  }
}

# Mandatory tag variables (required by all modules)
variable "contact_group" {
  description = "Contact group for the resources"
  type        = string
  default     = "DevOps Team"
}

variable "contact_name" {
  description = "Contact name for the resources"
  type        = string
  default     = "DevOps Admin"
}

variable "cost_bucket" {
  description = "Cost bucket for the resources"
  type        = string
  default     = "infrastructure"
}

variable "data_owner" {
  description = "Data owner for the resources"
  type        = string
  default     = "Data Team"
}

variable "display_name" {
  description = "Display name for the resources"
  type        = string
  default     = "Infrastructure Resources"
}

variable "has_public_ip" {
  description = "Whether the resources have public IP"
  type        = string
  default     = "false"
}

variable "has_unisys_network_connection" {
  description = "Whether the resources have Unisys network connection"
  type        = string
  default     = "false"
}

variable "service_line" {
  description = "Service line for the resources"
  type        = string
  default     = "Infrastructure"
}

# Network Variables (manually created VPC/subnets)
variable "vpc_id" {
  description = "VPC ID for resources"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

# EKS Variables
variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "my-eks-cluster"
}

variable "eks_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "eks_desired_size" {
  description = "Desired size for EKS node group"
  type        = number
  default     = 3
}

variable "eks_max_size" {
  description = "Maximum size for EKS node group"
  type        = number
  default     = 5
}

variable "eks_min_size" {
  description = "Minimum size for EKS node group"
  type        = number
  default     = 3
}

# RDS Variables
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.m5.xlarge"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 100
}

variable "rds_engine_version" {
  description = "RDS PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "rds_database_name" {
  description = "RDS database name"
  type        = string
  default     = "postgres"
}

variable "rds_username" {
  description = "RDS master username"
  type        = string
  default     = "postgres"
}

# S3 Variables
variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "my-project-data-bucket"
}

# Glue Variables
variable "glue_database_name" {
  description = "Glue database name"
  type        = string
  default     = "my_glue_database"
}

# Lambda Variables
variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "my-lambda-function"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

# OpenSearch Variables
variable "opensearch_domain_name" {
  description = "OpenSearch domain name"
  type        = string
  default     = "my-opensearch"
}

variable "opensearch_instance_type" {
  description = "OpenSearch instance type"
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_instance_count" {
  description = "OpenSearch instance count"
  type        = number
  default     = 1
}

# Kendra Variables
variable "kendra_index_name" {
  description = "Kendra index name"
  type        = string
  default     = "my-kendra-index"
}

variable "kendra_edition" {
  description = "Kendra edition"
  type        = string
  default     = "DEVELOPER_EDITION"
}

# SES Variables
variable "ses_email_addresses" {
  description = "List of email addresses to verify"
  type        = list(string)
  default     = ["admin@example.com"]
}

# ECR Variables
variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "my-app-repo"
}

# Step Functions Variables
variable "step_functions_definition" {
  description = "Step Functions state machine definition"
  type        = string
  default     = <<EOF
{
  "Comment": "A Hello World example",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Pass",
      "Result": "Hello World!",
      "End": true
    }
  }
}
EOF
}
