
# Project Configuration
project_name = "aws-infrastructure-project"
environment  = "dev"
region       = "us-east-1"

# EKS Configuration
eks_cluster_name       = "sc-eks-demo"
eks_kubernetes_version = "1.28"
eks_instance_types     = ["m5.xlarge"]
eks_desired_size       = 3
eks_max_size          = 5
eks_min_size          = 3
eks_disk_size         = 50
eks_capacity_type     = "ON_DEMAND"

# RDS Configuration
rds_db_identifier                 = "sc-rds-postgres-demo"
rds_engine_version               = "15.4"
rds_instance_class               = "db.m5.xlarge"
rds_allocated_storage            = 100
rds_max_allocated_storage        = 1000
rds_storage_type                 = "gp3"
rds_storage_encrypted            = true
rds_db_name                      = "postgres"
rds_db_username                  = "postgres"
rds_publicly_accessible         = false
rds_backup_retention_period      = 7
rds_multi_az                     = true
rds_monitoring_interval          = 60
rds_performance_insights_enabled = true
rds_deletion_protection          = true
rds_skip_final_snapshot          = false

# S3 Configuration
s3_bucket_name            = "sc-s3-demo"
s3_versioning_enabled     = true
s3_encryption_algorithm   = "AES256"
s3_block_public_access    = true
s3_lifecycle_enabled      = false
s3_notification_enabled   = false
s3_force_destroy          = false

# Glue Configuration
glue_database_name               = "sc-glue-demo"
glue_version                     = "5.0"
glue_worker_type                 = "G.1X"
glue_number_of_workers           = 5
glue_enable_job_bookmarks        = true
glue_enable_metrics              = true
glue_enable_continuous_logging   = true
glue_log_group_retention_days    = 14

# Lambda Configuration
lambda_function_name      = "sc-lambda-transcribeHandler-demo"
lambda_runtime           = "python3.9"
lambda_handler           = "index.handler"
lambda_memory_size       = 128
lambda_timeout           = 3
lambda_description       = "Lambda function for transcribe handling"
lambda_log_retention_days = 14

# Step Functions Configuration
stepfunctions_state_machine_name   = "sc-stepfn-demo"
stepfunctions_type                = "STANDARD"
stepfunctions_enable_logging      = true
stepfunctions_enable_tracing      = true
stepfunctions_enable_encryption   = true
stepfunctions_log_level           = "ERROR"
stepfunctions_log_retention_days  = 14

# Secrets Manager Configuration
secrets_secret_name                = "sc-secrets-dbcreds-demo"
secrets_secret_description         = "Database credentials for RDS"
secrets_create_kms_key             = true
secrets_enable_automatic_rotation  = false
secrets_rotation_days              = 30
secrets_recovery_window_in_days    = 30
secrets_allow_lambda_access        = true
secrets_allow_ecs_access           = true
secrets_allow_rds_access           = true

# Bedrock Configuration
bedrock_service_name = "sc-bedrock-textgen-demo"
bedrock_enabled_models = [
  "amazon.titan-embed-text-v2:0",
  "anthropic.claude-3-haiku-20240307-v1:0",
  "anthropic.claude-3-5-sonnet-20240620-v1:0",
  "anthropic.claude-3-5-haiku-20241022-v1:0"
]
bedrock_embedding_model_id                = "amazon.titan-embed-text-v2:0"
bedrock_log_retention_days               = 14
bedrock_enable_model_invocation_logging  = true
bedrock_create_cloudwatch_dashboard      = false
bedrock_create_lambda_execution_role     = false
bedrock_create_knowledge_base            = false

# OpenSearch Configuration
opensearch_domain_name                    = "sc-opensearch-logs-demo"
opensearch_engine_version                = "OpenSearch_2.3"
opensearch_instance_type                 = "r7g.xlarge.search"
opensearch_instance_count                = 1
opensearch_zone_awareness_enabled        = false
opensearch_availability_zone_count       = 1
opensearch_ebs_enabled                   = true
opensearch_volume_type                   = "gp3"
opensearch_volume_size                   = 20
opensearch_encrypt_at_rest               = true
opensearch_node_to_node_encryption       = true
opensearch_enforce_https                 = true
opensearch_advanced_security_enabled     = true
opensearch_internal_user_database_enabled = true
opensearch_master_user_name              = "admin"
opensearch_master_user_password          = "TempPassword123!"
opensearch_log_retention_days            = 14
opensearch_enable_slow_logs              = false
opensearch_enable_application_logs       = false

# CloudWatch Configuration
cloudwatch_service_name                     = "sc-cw-monitoring-demo"
cloudwatch_log_group_name                   = "sc-cw-monitoring-demo"
cloudwatch_log_retention_days               = 30
cloudwatch_create_sns_topic                 = true
cloudwatch_create_infrastructure_dashboard  = true
cloudwatch_create_application_dashboard     = true
cloudwatch_enable_cpu_alarms                = true
cloudwatch_enable_memory_alarms             = true
cloudwatch_enable_disk_alarms               = true
cloudwatch_alert_email_addresses            = []

# SES Configuration
ses_service_name                    = "sc-ses-emailservice-demo"
ses_email_address                   = "cicloudforteaimlnotifications@unisys.com"
ses_create_configuration_set        = true
ses_tls_policy                      = "Require"
ses_reputation_metrics_enabled      = true
ses_enable_cloudwatch_destination   = true
ses_enable_bounce_topic             = true
ses_enable_complaint_topic          = true
ses_log_retention_days              = 30
ses_create_sending_quota_alarm      = true
ses_create_bounce_rate_alarm        = true
ses_create_complaint_rate_alarm     = true

# ECR Configuration
ecr_repository_name         = "sc-ecr-demo"
ecr_image_tag_mutability    = "MUTABLE"
ecr_force_delete           = false
ecr_scan_on_push           = true
ecr_encryption_type        = "AES256"
ecr_kms_key_id             = null
ecr_enable_lifecycle_policy = true
ecr_max_image_count        = 10
ecr_untagged_image_days    = 7

# Network Configuration
vpc_id             = "vpc-xxxxxxxxxxxxxxxxx"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Subnet Configuration
eks_subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxxx",
  "subnet-yyyyyyyyyyyyyyyyy",
  "subnet-zzzzzzzzzzzzzzzzz"
]

rds_subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxxx",
  "subnet-yyyyyyyyyyyyyyyyy"
]

s3_subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxxx",
  "subnet-yyyyyyyyyyyyyyyyy"
]

ecr_subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxxx",
  "subnet-yyyyyyyyyyyyyyyyy"
]

opensearch_subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxxx",
  "subnet-yyyyyyyyyyyyyyyyy"
]

# Mandatory Organizational Tags
contact_group                 = "infrastructure-team"
contact_name                  = "john.doe@company.com"
cost_bucket                   = "engineering-infrastructure"
data_owner                    = "data-engineering-team"
display_name                  = "AWS Infrastructure Project - Development"
has_public_ip                 = "false"
has_unisys_network_connection = "true"
service_line                  = "platform-engineering"
