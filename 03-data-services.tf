
# =============================================================================
# Data Services Configuration
# File 3 of 5: RDS, S3, Glue, Step Functions, and OpenSearch resources
# =============================================================================

# Data sources to reference previous resources
data "aws_ssm_parameter" "project_config_data" {
  name = "/${var.project_name}/config/base"
}

data "aws_ssm_parameter" "compute_config" {
  name = "/${var.project_name}/config/compute"
}

locals {
  project_config_data = jsondecode(data.aws_ssm_parameter.project_config_data.value)
  compute_config = jsondecode(data.aws_ssm_parameter.compute_config.value)
}

# =============================================================================
# Resource 1: AWS RDS PostgreSQL (sc-rds-postgres-demo)
# =============================================================================

module "rds_postgres" {
  source = "./rds_postgres"

  db_identifier = "${local.project_config_data.service_prefix}-rds-postgres-${var.environment}"
  engine_version = "15.4"
  instance_class = var.rds_instance_class
  
  allocated_storage = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type = "gp3"
  storage_encrypted = var.enable_encryption
  
  db_name = "studycompanion"
  db_username = "postgres"
  
  vpc_id = local.project_config_data.vpc_id
  subnet_ids = local.project_config_data.private_subnet_ids
  allowed_security_groups = [
    local.compute_config.eks_cluster_security_group_id,
    local.project_config_data.lambda_sg_id,
    local.project_config_data.database_sg_id
  ]
  
  backup_retention_period = var.backup_retention_period
  backup_window = "03:00-04:00"
  maintenance_window = "sun:04:00-sun:05:00"
  multi_az = false
  
  performance_insights_enabled = var.enable_detailed_monitoring
  monitoring_interval = var.enable_detailed_monitoring ? 60 : 0
  
  deletion_protection = var.enable_deletion_protection
  skip_final_snapshot = !var.enable_deletion_protection

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "Database"
    Engine    = "PostgreSQL"
    Service   = "RDS"
  }

  depends_on = [
    data.aws_ssm_parameter.project_config_data,
    data.aws_ssm_parameter.compute_config
  ]
}

# =============================================================================
# Resource 2: AWS S3 Bucket (sc-s3-demo)
# =============================================================================

module "s3_bucket" {
  source = "./s3_bucket"

  bucket_name = "${local.project_config_data.service_prefix}-s3-${var.environment}-${local.project_config_data.bucket_suffix}"
  versioning_enabled = true
  encryption_algorithm = var.enable_encryption ? "AES256" : "AES256"
  force_destroy = !var.enable_deletion_protection

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "Storage"
    Purpose   = "ApplicationData"
    Service   = "S3"
  }
}

# S3 Bucket Policy for Lambda and Glue access
resource "aws_s3_bucket_policy" "application_bucket_policy" {
  bucket = module.s3_bucket.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaAccess"
        Effect = "Allow"
        Principal = {
          AWS = local.compute_config.lambda_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${module.s3_bucket.bucket_arn}/*"
      },
      {
        Sid    = "AllowGlueAccess"
        Effect = "Allow"
        Principal = {
          AWS = local.project_config_data.glue_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.s3_bucket.bucket_arn,
          "${module.s3_bucket.bucket_arn}/*"
        ]
      }
    ]
  })

  depends_on = [module.s3_bucket]
}

# =============================================================================
# Resource 3: AWS Glue (sc-glue-demo)
# =============================================================================

module "glue" {
  source = "./glue"

  database_name = "${local.project_config_data.service_prefix}-glue-${var.environment}"
  s3_bucket_name = module.s3_bucket.bucket_id
  
  glue_jobs = {
    data_processor = {
      description = "Process study companion data for analytics and ML"
      script_location = "s3://${module.s3_bucket.bucket_id}/scripts/data_processor.py"
      glue_version = var.glue_version
      python_version = "3"
      worker_type = var.glue_worker_type
      number_of_workers = var.glue_number_of_workers
      max_concurrent_runs = 1
      max_retries = 1
      timeout = 60
      default_arguments = {
        "--enable-continuous-cloudwatch-log" = "true"
        "--enable-spark-ui" = "true"
        "--enable-metrics" = ""
        "--S3_BUCKET" = module.s3_bucket.bucket_id
        "--DATABASE_NAME" = module.rds_postgres.db_name
        "--DATABASE_HOST" = module.rds_postgres.db_instance_endpoint
        "--SECRETS_ARN" = local.project_config_data.db_secrets_arn
      }
    }
    
    etl_processor = {
      description = "ETL processing for study companion documents"
      script_location = "s3://${module.s3_bucket.bucket_id}/scripts/etl_processor.py"
      glue_version = var.glue_version
      python_version = "3"
      worker_type = var.glue_worker_type
      number_of_workers = 2
      max_concurrent_runs = 2
      max_retries = 2
      timeout = 120
      default_arguments = {
        "--enable-continuous-cloudwatch-log" = "true"
        "--enable-spark-ui" = "true"
        "--S3_INPUT_PATH" = "s3://${module.s3_bucket.bucket_id}/raw/"
        "--S3_OUTPUT_PATH" = "s3://${module.s3_bucket.bucket_id}/processed/"
      }
    }
  }

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "DataProcessing"
    Service   = "Glue"
    Purpose   = "ETLProcessing"
  }

  depends_on = [module.s3_bucket, module.rds_postgres]
}

# =============================================================================
# Resource 4: AWS Step Functions (sc-stepfn-demo)
# =============================================================================

module "step_functions" {
  source = "./step_functions"

  state_machine_name = "${local.project_config_data.service_prefix}-stepfn-${var.environment}"
  type = "STANDARD"
  
  definition = jsonencode({
    Comment = "Study Companion data processing workflow"
    StartAt = "ProcessDocument"
    States = {
      ProcessDocument = {
        Type = "Task"
        Resource = local.compute_config.lambda_function_arn
        Parameters = {
          "input.$" = "$"
          "operation" = "process_document"
        }
        Retry = [
          {
            ErrorEquals = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"]
            IntervalSeconds = 2
            MaxAttempts = 6
            BackoffRate = 2
          }
        ]
        Next = "CheckProcessingResult"
      }
      
      CheckProcessingResult = {
        Type = "Choice"
        Choices = [
          {
            Variable = "$.status"
            StringEquals = "success"
            Next = "StartGlueJob"
          },
          {
            Variable = "$.status"
            StringEquals = "retry"
            Next = "WaitAndRetry"
          }
        ]
        Default = "ProcessingFailed"
      }
      
      WaitAndRetry = {
        Type = "Wait"
        Seconds = 30
        Next = "ProcessDocument"
      }
      
      StartGlueJob = {
        Type = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = "${local.project_config_data.service_prefix}-glue-${var.environment}-data_processor"
          Arguments = {
            "--input_path.$" = "$.input_path"
            "--output_path.$" = "$.output_path"
          }
        }
        Retry = [
          {
            ErrorEquals = ["States.TaskFailed"]
            IntervalSeconds = 30
            MaxAttempts = 3
            BackoffRate = 2
          }
        ]
        Next = "ProcessingComplete"
      }
      
      ProcessingComplete = {
        Type = "Pass"
        Result = {
          "status" = "completed"
          "message" = "Document processing workflow completed successfully"
        }
        End = true
      }
      
      ProcessingFailed = {
        Type = "Fail"
        Cause = "Document processing failed"
        Error = "ProcessingError"
      }
    }
  })
  
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
  ]
  
  custom_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = local.compute_config.lambda_function_arn
      },
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:BatchStopJobRun",
          "glue:GetJobRuns"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          module.s3_bucket.bucket_arn,
          "${module.s3_bucket.bucket_arn}/*"
        ]
      }
    ]
  })
  
  enable_logging = true
  log_level = "ERROR"
  enable_tracing = var.enable_detailed_monitoring
  
  log_retention_days = var.log_retention_days

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "Orchestration"
    Service   = "StepFunctions"
    Purpose   = "DataProcessingWorkflow"
  }

  depends_on = [
    module.glue,
    data.aws_ssm_parameter.compute_config,
    module.s3_bucket
  ]
}

# =============================================================================
# Resource 5: AWS OpenSearch (sc-opensearch-logs-demo)
# =============================================================================

module "opensearch" {
  source = "./opensearch"

  domain_name = "${local.project_config_data.service_prefix}-opensearch-logs-${var.environment}"
  engine_version = "OpenSearch_2.3"
  
  instance_type = var.opensearch_instance_type
  instance_count = var.opensearch_instance_count
  zone_awareness_enabled = false
  
  ebs_enabled = true
  volume_type = "gp3"
  volume_size = var.opensearch_volume_size
  
  encrypt_at_rest = var.enable_encryption
  node_to_node_encryption = var.enable_encryption
  enforce_https = true
  
  vpc_id = local.project_config_data.vpc_id
  subnet_ids = [local.project_config_data.private_subnet_ids[0]]
  allowed_security_groups = [
    local.compute_config.eks_cluster_security_group_id,
    local.project_config_data.lambda_sg_id,
    local.project_config_data.opensearch_sg_id
  ]
  
  advanced_security_enabled = true
  internal_user_database_enabled = true
  master_user_name = "admin"
  master_user_password = random_password.opensearch_password.result
  
  enable_slow_logs = var.enable_detailed_monitoring
  enable_application_logs = var.enable_detailed_monitoring
  log_retention_days = var.log_retention_days

  # Access policy for application services
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            local.compute_config.lambda_role_arn,
            local.project_config_data.glue_role_arn
          ]
        }
        Action = [
          "es:ESHttpGet",
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpDelete"
        ]
        Resource = "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${local.project_config_data.service_prefix}-opensearch-logs-${var.environment}/*"
      }
    ]
  })

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "Search"
    Purpose   = "LoggingAndAnalytics"
    Service   = "OpenSearch"
  }

  depends_on = [
    data.aws_ssm_parameter.project_config_data,
    data.aws_ssm_parameter.compute_config
  ]
}

# Random password for OpenSearch master user
resource "random_password" "opensearch_password" {
  length = 16
  special = true
  
  lifecycle {
    ignore_changes = [length, special]
  }
}

# Store OpenSearch credentials in Secrets Manager
resource "aws_secretsmanager_secret" "opensearch_credentials" {
  name        = "${local.project_config_data.service_prefix}-opensearch-credentials-${var.environment}"
  description = "OpenSearch master user credentials"
  
  recovery_window_in_days = 7

  tags = merge(local.mandatory_tags, {
    Name      = "${local.project_config_data.service_prefix}-opensearch-credentials-${var.environment}"
    Component = "Security"
    Purpose   = "OpenSearchCredentials"
  })
}

resource "aws_secretsmanager_secret_version" "opensearch_credentials" {
  secret_id = aws_secretsmanager_secret.opensearch_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.opensearch_password.result
    endpoint = module.opensearch.endpoint
    kibana_endpoint = module.opensearch.kibana_endpoint
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# =============================================================================
# Data Sources and Supporting Resources
# =============================================================================

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Update project config with data service outputs
resource "aws_ssm_parameter" "data_config" {
  name  = "/${var.project_name}/config/data"
  type  = "String"
  value = jsonencode({
    # RDS Configuration
    rds_instance_id = module.rds_postgres.db_instance_id
    rds_instance_arn = module.rds_postgres.db_instance_arn
    rds_endpoint = module.rds_postgres.db_instance_endpoint
    rds_port = module.rds_postgres.db_instance_port
    rds_database_name = module.rds_postgres.db_name
    rds_security_group_id = module.rds_postgres.db_security_group_id
    
    # S3 Configuration
    s3_bucket_id = module.s3_bucket.bucket_id
    s3_bucket_arn = module.s3_bucket.bucket_arn
    s3_bucket_domain_name = module.s3_bucket.bucket_domain_name
    
    # Glue Configuration
    glue_database_name = module.glue.database_name
    glue_database_arn = module.glue.database_arn
    glue_job_names = module.glue.job_names
    glue_job_arns = module.glue.job_arns
    
    # Step Functions Configuration
    step_function_arn = module.step_functions.state_machine_arn
    step_function_name = module.step_functions.state_machine_name
    step_function_role_arn = module.step_functions.role_arn
    
    # OpenSearch Configuration
    opensearch_domain_arn = module.opensearch.domain_arn
    opensearch_domain_id = module.opensearch.domain_id
    opensearch_endpoint = module.opensearch.endpoint
    opensearch_kibana_endpoint = module.opensearch.kibana_endpoint
    opensearch_dashboard_endpoint = module.opensearch.dashboard_endpoint
    opensearch_security_group_id = module.opensearch.security_group_id
    opensearch_credentials_arn = aws_secretsmanager_secret.opensearch_credentials.arn
  })

  tags = merge(local.mandatory_tags, {
    Name      = "${var.project_name}-data-config"
    Component = "Configuration"
    Purpose   = "CrossFileReference"
  })

  depends_on = [
    module.rds_postgres,
    module.s3_bucket,
    module.glue,
    module.step_functions,
    module.opensearch,
    aws_secretsmanager_secret.opensearch_credentials
  ]
}

# CloudWatch Log Groups for data services
resource "aws_cloudwatch_log_group" "data_logs" {
  name              = "/aws/${var.project_name}/${var.environment}/data"
  retention_in_days = var.log_retention_days

  tags = merge(local.mandatory_tags, {
    Name      = "${local.project_config_data.service_prefix}-data-logs-${var.environment}"
    Component = "Monitoring"
    Purpose   = "DataLogging"
    Service   = "CloudWatch"
  })
}
