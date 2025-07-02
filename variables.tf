
# AWS Region Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1", "ap-southeast-1"
    ], var.aws_region)
    error_message = "AWS region must be a valid region."
  }
}

# Environment Configuration
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod, demo)"
  type        = string
  default     = "demo"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "study-companion"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

# Existing Network Configuration (DO NOT CREATE - USE EXISTING)
variable "vpc_id" {
  description = "ID of existing VPC where resources will be deployed"
  type        = string
  validation {
    condition     = can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "VPC ID must be a valid AWS VPC identifier (vpc-xxxxxxxx)."
  }
}

variable "public_subnet_ids" {
  description = "List of existing public subnet IDs"
  type        = list(string)
  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least 2 public subnets are required for high availability."
  }
  validation {
    condition = alltrue([
      for subnet_id in var.public_subnet_ids : can(regex("^subnet-[a-z0-9]+$", subnet_id))
    ])
    error_message = "All subnet IDs must be valid AWS subnet identifiers (subnet-xxxxxxxx)."
  }
}

variable "private_subnet_ids" {
  description = "List of existing private subnet IDs"
  type        = list(string)
  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least 2 private subnets are required for high availability."
  }
  validation {
    condition = alltrue([
      for subnet_id in var.private_subnet_ids : can(regex("^subnet-[a-z0-9]+$", subnet_id))
    ])
    error_message = "All subnet IDs must be valid AWS subnet identifiers (subnet-xxxxxxxx)."
  }
}

variable "availability_zones" {
  description = "List of availability zones matching the subnets"
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones are required for high availability."
  }
}

# EKS Configuration
variable "eks_node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
  default     = ["m5.xlarge"]
  validation {
    condition = alltrue([
      for instance_type in var.eks_node_instance_types : can(regex("^[a-z0-9]+\\.[a-z0-9]+$", instance_type))
    ])
    error_message = "All instance types must be valid AWS instance types (e.g., m5.xlarge)."
  }
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 3
  validation {
    condition     = var.eks_node_desired_size >= 1 && var.eks_node_desired_size <= 20
    error_message = "EKS node desired size must be between 1 and 20."
  }
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 6
  validation {
    condition     = var.eks_node_max_size >= 1 && var.eks_node_max_size <= 50
    error_message = "EKS node max size must be between 1 and 50."
  }
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.eks_node_min_size >= 1 && var.eks_node_min_size <= 10
    error_message = "EKS node min size must be between 1 and 10."
  }
}

# RDS Configuration
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.m5.xlarge"
  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.rds_instance_class))
    error_message = "RDS instance class must be a valid AWS RDS instance type (e.g., db.m5.xlarge)."
  }
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 100
  validation {
    condition     = var.rds_allocated_storage >= 20 && var.rds_allocated_storage <= 65536
    error_message = "RDS allocated storage must be between 20 and 65536 GB."
  }
}

variable "rds_max_allocated_storage" {
  description = "RDS maximum allocated storage in GB"
  type        = number
  default     = 1000
  validation {
    condition     = var.rds_max_allocated_storage >= 100 && var.rds_max_allocated_storage <= 65536
    error_message = "RDS max allocated storage must be between 100 and 65536 GB."
  }
}

# OpenSearch Configuration
variable "opensearch_instance_type" {
  description = "OpenSearch instance type"
  type        = string
  default     = "r7g.xlarge.search"
  validation {
    condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+\\.search$", var.opensearch_instance_type))
    error_message = "OpenSearch instance type must be a valid search instance type (e.g., r7g.xlarge.search)."
  }
}

variable "opensearch_instance_count" {
  description = "Number of OpenSearch instances"
  type        = number
  default     = 1
  validation {
    condition     = var.opensearch_instance_count >= 1 && var.opensearch_instance_count <= 20
    error_message = "OpenSearch instance count must be between 1 and 20."
  }
}

variable "opensearch_volume_size" {
  description = "OpenSearch EBS volume size in GB"
  type        = number
  default     = 100
  validation {
    condition     = var.opensearch_volume_size >= 10 && var.opensearch_volume_size <= 3584
    error_message = "OpenSearch volume size must be between 10 and 3584 GB."
  }
}

# Lambda Configuration
variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "python3.9"
  validation {
    condition = contains([
      "python3.8", "python3.9", "python3.10", "python3.11",
      "nodejs16.x", "nodejs18.x", "nodejs20.x",
      "java8", "java11", "java17", "java21"
    ], var.lambda_runtime)
    error_message = "Lambda runtime must be a supported AWS Lambda runtime."
  }
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 512
  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory size must be between 128 and 10240 MB."
  }
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 300
  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 1 and 900 seconds."
  }
}

# Monitoring Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for resources"
  type        = bool
  default     = true
}

# Email Configuration
variable "alert_email_addresses" {
  description = "Email addresses for alerts"
  type        = list(string)
  default     = ["admin@studycompanion.com"]
  validation {
    condition = alltrue([
      for email in var.alert_email_addresses : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All email addresses must be valid email format."
  }
}

variable "ses_domain_name" {
  description = "Domain name for SES"
  type        = string
  default     = "studycompanion.com"
  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.ses_domain_name))
    error_message = "SES domain name must be a valid domain format."
  }
}

# Security Configuration
variable "enable_encryption" {
  description = "Enable encryption for supported resources"
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for critical resources"
  type        = bool
  default     = false
}

# Cost Optimization
variable "enable_cost_optimization" {
  description = "Enable cost optimization features"
  type        = bool
  default     = true
}

# Backup Configuration
variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

# Bedrock Configuration
variable "bedrock_models" {
  description = "List of Bedrock models to enable"
  type        = list(string)
  default = [
    "amazon.titan-embed-text-v2:0",
    "anthropic.claude-3-haiku-20240307-v1:0",
    "anthropic.claude-3-5-sonnet-20241022-v2:0",
    "anthropic.claude-3-5-haiku-20241022-v1:0"
  ]
}

# Glue Configuration
variable "glue_version" {
  description = "AWS Glue version"
  type        = string
  default     = "4.0"
  validation {
    condition     = contains(["2.0", "3.0", "4.0"], var.glue_version)
    error_message = "Glue version must be 2.0, 3.0, or 4.0."
  }
}

variable "glue_worker_type" {
  description = "Glue worker type"
  type        = string
  default     = "G.1X"
  validation {
    condition     = contains(["Standard", "G.1X", "G.2X", "G.025X"], var.glue_worker_type)
    error_message = "Glue worker type must be Standard, G.1X, G.2X, or G.025X."
  }
}

variable "glue_number_of_workers" {
  description = "Number of Glue workers"
  type        = number
  default     = 2
  validation {
    condition     = var.glue_number_of_workers >= 2 && var.glue_number_of_workers <= 299
    error_message = "Number of Glue workers must be between 2 and 299."
  }
}

# Common Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "demo"
    Project     = "study-companion"
    ManagedBy   = "terraform"
  }
}

# Local values for consistent configuration
locals {
  mandatory_tags = merge(var.common_tags, {
    Environment = var.environment
    Project     = var.project_name
    Owner       = "DevOps Team"
    ManagedBy   = "Terraform"
  })

  service_prefix = "sc"
  cluster_name = "${local.service_prefix}-eks-${var.environment}"
  
  # Common naming patterns
  resource_prefix = "${local.service_prefix}-${var.environment}"
  
  # Network validation
  subnet_count_match = length(var.public_subnet_ids) == length(var.private_subnet_ids) && 
                      length(var.public_subnet_ids) == length(var.availability_zones)
}

# Validation for subnet and AZ alignment
resource "null_resource" "validate_network_config" {
  count = local.subnet_count_match ? 0 : 1
  
  provisioner "local-exec" {
    command = "echo 'Error: Number of public subnets, private subnets, and availability zones must match' && exit 1"
  }
}
