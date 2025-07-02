
# Common Configuration
aws_region   = "us-east-1"
environment  = "dev"
project_name = "my-project"

common_tags = {
  Environment = "dev"
  Project     = "my-project"
  ManagedBy   = "terraform"
  Owner       = "DevOps Team"
}

# Mandatory Tags
contact_group                   = "DevOps Team"
contact_name                    = "DevOps Admin"
cost_bucket                     = "infrastructure"
data_owner                      = "Data Team"
display_name                    = "Infrastructure Resources"
has_public_ip                   = "false"
has_unisys_network_connection   = "false"
service_line                    = "Infrastructure"

# Network Configuration (Update these with your actual VPC/subnet IDs)
vpc_id             = "vpc-xxxxxxxxx"
private_subnet_ids = ["subnet-xxxxxxxxx", "subnet-yyyyyyyyy"]
public_subnet_ids  = ["subnet-zzzzzzzzz", "subnet-aaaaaaaaa"]

# EKS Configuration
eks_cluster_name    = "my-eks-cluster"
eks_instance_types  = ["m5.xlarge"]
eks_desired_size    = 3
eks_max_size        = 5
eks_min_size        = 3

# RDS Configuration
rds_instance_class    = "db.m5.xlarge"
rds_allocated_storage = 100
rds_engine_version    = "15.4"
rds_database_name     = "postgres"
rds_username          = "postgres"

# S3 Configuration
s3_bucket_name = "my-project-data-bucket"

# Glue Configuration
glue_database_name = "my_glue_database"

# Lambda Configuration
lambda_function_name = "my-lambda-function"
lambda_runtime       = "python3.11"

# OpenSearch Configuration
opensearch_domain_name   = "my-opensearch"
opensearch_instance_type = "t3.small.search"
opensearch_instance_count = 1

# Kendra Configuration
kendra_index_name = "my-kendra-index"
kendra_edition    = "DEVELOPER_EDITION"

# SES Configuration
ses_email_addresses = ["admin@example.com"]

# ECR Configuration
ecr_repository_name = "my-app-repo"
