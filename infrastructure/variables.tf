
# Common Variables
variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# EKS Variables
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "eks_instance_types" {
  description = "List of instance types for the EKS Node Group"
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "eks_desired_size" {
  description = "Desired number of nodes in the EKS Node Group"
  type        = number
  default     = 3
}

variable "eks_max_size" {
  description = "Maximum number of nodes in the EKS Node Group"
  type        = number
  default     = 5
}

variable "eks_min_size" {
  description = "Minimum number of nodes in the EKS Node Group"
  type        = number
  default     = 3
}

variable "eks_disk_size" {
  description = "Disk size in GiB for EKS worker nodes"
  type        = number
  default     = 50
}

variable "eks_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group"
  type        = string
  default     = "ON_DEMAND"
}

# RDS Variables
variable "rds_db_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.m5.xlarge"
}

variable "rds_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 100
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB"
  type        = number
  default     = 1000
}

variable "rds_storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp3"
}

variable "rds_storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "rds_db_name" {
  description = "Name of the initial database"
  type        = string
  default     = "postgres"
}

variable "rds_db_username" {
  description = "Master username for the database"
  type        = string
  default     = "postgres"
}

variable "rds_publicly_accessible" {
  description = "Make the RDS instance publicly accessible"
  type        = bool
  default     = false
}

variable "rds_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "rds_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds"
  type        = number
  default     = 60
}

variable "rds_performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot when deleting"
  type        = bool
  default     = false
}

# S3 Variables
variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "s3_versioning_enabled" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_encryption_algorithm" {
  description = "Server-side encryption algorithm to use"
  type        = string
  default     = "AES256"
}

variable "s3_block_public_access" {
  description = "Enable S3 bucket public access block"
  type        = bool
  default     = true
}

variable "s3_lifecycle_enabled" {
  description = "Enable lifecycle configuration for the S3 bucket"
  type        = bool
  default     = false
}

variable "s3_notification_enabled" {
  description = "Enable S3 bucket notifications"
  type        = bool
  default     = false
}

variable "s3_force_destroy" {
  description = "Boolean that indicates all objects should be deleted from the bucket when the bucket is destroyed"
  type        = bool
  default     = false
}

# Glue Variables
variable "glue_database_name" {
  description = "Name of the Glue catalog database"
  type        = string
}

variable "glue_version" {
  description = "Version of AWS Glue to use"
  type        = string
  default     = "5.0"
}

variable "glue_worker_type" {
  description = "Type of predefined worker for Glue jobs"
  type        = string
  default     = "G.1X"
}

variable "glue_number_of_workers" {
  description = "Number of workers for Glue jobs"
  type        = number
  default     = 5
}

variable "glue_enable_job_bookmarks" {
  description = "Enable job bookmarks for Glue jobs"
  type        = bool
  default     = true
}

variable "glue_enable_metrics" {
  description = "Enable CloudWatch metrics for Glue jobs"
  type        = bool
  default     = true
}

variable "glue_enable_continuous_logging" {
  description = "Enable continuous logging for Glue jobs"
  type        = bool
  default     = true
}

variable "glue_log_group_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 14
}

# Lambda Variables
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.9"
}

variable "lambda_handler" {
  description = "Function entrypoint in your code"
  type        = string
  default     = "index.handler"
}

variable "lambda_memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 3
}

variable "lambda_description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "lambda_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

# Step Functions Variables
variable "stepfunctions_state_machine_name" {
  description = "Name of the Step Functions state machine"
  type        = string
}

variable "stepfunctions_type" {
  description = "Type of state machine (STANDARD or EXPRESS)"
  type        = string
  default     = "STANDARD"
}

variable "stepfunctions_enable_logging" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
}

variable "stepfunctions_enable_tracing" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

variable "stepfunctions_enable_encryption" {
  description = "Enable encryption for the state machine"
  type        = bool
  default     = true
}

variable "stepfunctions_log_level" {
  description = "Log level for CloudWatch logging"
  type        = string
  default     = "ERROR"
}

variable "stepfunctions_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

# Secrets Manager Variables
variable "secrets_secret_name" {
  description = "Name of the secret"
  type        = string
}

variable "secrets_secret_description" {
  description = "Description of the secret"
  type        = string
  default     = "Database credentials for RDS"
}

variable "secrets_create_kms_key" {
  description = "Create a dedicated KMS key for this secret"
  type        = bool
  default     = true
}

variable "secrets_enable_automatic_rotation" {
  description = "Enable automatic rotation for the secret"
  type        = bool
  default     = false
}

variable "secrets_rotation_days" {
  description = "Number of days between automatic rotations"
  type        = number
  default     = 30
}

variable "secrets_recovery_window_in_days" {
  description = "Number of days before permanent deletion"
  type        = number
  default     = 30
}

variable "secrets_allow_lambda_access" {
  description = "Allow Lambda service to access this secret"
  type        = bool
  default     = true
}

variable "secrets_allow_ecs_access" {
  description = "Allow ECS tasks to access this secret"
  type        = bool
  default     = true
}

variable "secrets_allow_rds_access" {
  description = "Allow RDS service to access this secret"
  type        = bool
  default     = true
}

# Bedrock Variables
variable "bedrock_service_name" {
  description = "Name of the Bedrock service"
  type        = string
}

variable "bedrock_enabled_models" {
  description = "List of enabled Bedrock foundation models"
  type        = list(string)
  default     = []
}

variable "bedrock_embedding_model_id" {
  description = "Model ID used for text embeddings"
  type        = string
  default     = "amazon.titan-embed-text-v2:0"
}

variable "bedrock_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "bedrock_enable_model_invocation_logging" {
  description = "Enable logging of model invocations"
  type        = bool
  default     = true
}

variable "bedrock_create_cloudwatch_dashboard" {
  description = "Create CloudWatch dashboard for monitoring"
  type        = bool
  default     = false
}

variable "bedrock_create_lambda_execution_role" {
  description = "Whether to create a Lambda execution role"
  type        = bool
  default     = false
}

variable "bedrock_create_knowledge_base" {
  description = "Whether to create a knowledge base"
  type        = bool
  default     = false
}

# OpenSearch Variables
variable "opensearch_domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
}

variable "opensearch_engine_version" {
  description = "OpenSearch engine version"
  type        = string
  default     = "OpenSearch_2.3"
}

variable "opensearch_instance_type" {
  description = "Instance type for OpenSearch nodes"
  type        = string
  default     = "r7g.xlarge.search"
}

variable "opensearch_instance_count" {
  description = "Number of instances in the cluster"
  type        = number
  default     = 1
}

variable "opensearch_zone_awareness_enabled" {
  description = "Enable zone awareness"
  type        = bool
  default     = false
}

variable "opensearch_availability_zone_count" {
  description = "Number of availability zones"
  type        = number
  default     = 1
}

variable "opensearch_ebs_enabled" {
  description = "Enable EBS volumes"
  type        = bool
  default     = true
}

variable "opensearch_volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp3"
}

variable "opensearch_volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 20
}

variable "opensearch_encrypt_at_rest" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "opensearch_node_to_node_encryption" {
  description = "Enable node-to-node encryption"
  type        = bool
  default     = true
}

variable "opensearch_enforce_https" {
  description = "Enforce HTTPS"
  type        = bool
  default     = true
}

variable "opensearch_advanced_security_enabled" {
  description = "Enable advanced security options (fine-grained access control)"
  type        = bool
  default     = true
}

variable "opensearch_internal_user_database_enabled" {
  description = "Enable internal user database"
  type        = bool
  default     = true
}

variable "opensearch_master_user_name" {
  description = "Master user name for advanced security"
  type        = string
  default     = "admin"
}

variable "opensearch_master_user_password" {
  description = "Master user password for advanced security"
  type        = string
  default     = "TempPassword123!"
  sensitive   = true
}

variable "opensearch_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "opensearch_enable_slow_logs" {
  description = "Enable slow logs"
  type        = bool
  default     = false
}

variable "opensearch_enable_application_logs" {
  description = "Enable application logs"
  type        = bool
  default     = false
}

# CloudWatch Variables
variable "cloudwatch_service_name" {
  description = "Name of the CloudWatch monitoring service"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "Name of the primary CloudWatch log group"
  type        = string
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "cloudwatch_create_sns_topic" {
  description = "Create SNS topic for CloudWatch alerts"
  type        = bool
  default     = true
}

variable "cloudwatch_create_infrastructure_dashboard" {
  description = "Create infrastructure monitoring dashboard"
  type        = bool
  default     = true
}

variable "cloudwatch_create_application_dashboard" {
  description = "Create application-specific dashboard"
  type        = bool
  default     = true
}

variable "cloudwatch_enable_cpu_alarms" {
  description = "Enable CPU utilization alarms"
  type        = bool
  default     = true
}

variable "cloudwatch_enable_memory_alarms" {
  description = "Enable memory utilization alarms"
  type        = bool
  default     = true
}

variable "cloudwatch_enable_disk_alarms" {
  description = "Enable disk space alarms"
  type        = bool
  default     = true
}

variable "cloudwatch_alert_email_addresses" {
  description = "List of email addresses to receive CloudWatch alerts"
  type        = list(string)
  default     = []
}

# Subnet Variables
variable "eks_subnet_ids" {
  description = "List of subnet IDs for EKS cluster"
  type        = list(string)
}

variable "rds_subnet_ids" {
  description = "List of subnet IDs for RDS instances"
  type        = list(string)
}

variable "s3_subnet_ids" {
  description = "List of subnet IDs for S3 VPC endpoints"
  type        = list(string)
  default     = []
}

variable "ecr_subnet_ids" {
  description = "List of subnet IDs for ECR VPC endpoints"
  type        = list(string)
  default     = []
}

variable "opensearch_subnet_ids" {
  description = "List of subnet IDs for OpenSearch cluster"
  type        = list(string)
}

# Mandatory Organizational Tags
variable "contact_group" {
  description = "Contact group responsible for the resource"
  type        = string
}

variable "contact_name" {
  description = "Contact person name responsible for the resource"
  type        = string
}

variable "cost_bucket" {
  description = "Cost bucket for billing allocation"
  type        = string
}

variable "data_owner" {
  description = "Data owner for the resource"
  type        = string
}

variable "display_name" {
  description = "Display name for the resource"
  type        = string
}

variable "has_public_ip" {
  description = "Whether the resource has public IP access"
  type        = string
  validation {
    condition     = contains(["true", "false"], var.has_public_ip)
    error_message = "has_public_ip must be either 'true' or 'false'."
  }
}

variable "has_unisys_network_connection" {
  description = "Whether the resource has Unisys network connection"
  type        = string
  validation {
    condition     = contains(["true", "false"], var.has_unisys_network_connection)
    error_message = "has_unisys_network_connection must be either 'true' or 'false'."
  }
}

variable "service_line" {
  description = "Service line for the resource"
  type        = string
}

# Additional Common Variables
variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
