
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Local tags configuration
locals {
  mandatory_tags = merge(var.common_tags, {
    contactGroup                = var.contact_group
    contactName                 = var.contact_name
    costBucket                  = var.cost_bucket
    dataOwner                   = var.data_owner
    displayName                 = var.display_name
    environment                 = var.environment
    hasPublicIP                 = var.has_public_ip
    hasUnisysNetworkConnection  = var.has_unisys_network_connection
    serviceLine                 = var.service_line
  })
  
  # Generate database secret JSON if using database template
  database_secret_json = var.database_secret_template && var.database_config != null ? jsonencode({
    engine   = var.database_config.engine
    host     = var.database_config.host
    port     = var.database_config.port
    dbname   = var.database_config.dbname
    username = var.database_config.username
    password = var.database_config.password
  }) : null
  
  # Generate API key secret JSON if using API key template
  api_key_secret_json = var.api_key_secret_template && var.api_key_config != null ? jsonencode({
    api_key    = var.api_key_config.api_key
    api_secret = var.api_key_config.api_secret
    endpoint   = var.api_key_config.endpoint
  }) : null
  
  # Generate OAuth secret JSON if using OAuth template
  oauth_secret_json = var.oauth_secret_template && var.oauth_config != null ? jsonencode({
    client_id     = var.oauth_config.client_id
    client_secret = var.oauth_config.client_secret
    token_url     = var.oauth_config.token_url
    scope         = var.oauth_config.scope
  }) : null
  
  # Determine final secret string
  final_secret_string = coalesce(
    var.secret_string,
    local.database_secret_json,
    local.api_key_secret_json,
    local.oauth_secret_json
  )
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get current AWS region
data "aws_region" "current" {}

# KMS Key for Secrets Manager encryption
resource "aws_kms_key" "secrets_manager_key" {
  count = var.create_kms_key ? 1 : 0

  description             = "KMS key for Secrets Manager encryption - ${var.secret_name}"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = var.enable_key_rotation
  rotation_period_in_days = var.key_rotation_period

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Secrets Manager to use the key"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.mandatory_tags,
    {
      Name    = "${var.secret_name}-kms-key"
      Purpose = "Database credentials encryption"
    }
  )
}

# KMS Alias for easier identification
resource "aws_kms_alias" "secrets_manager_key_alias" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${var.secret_name}-secrets-key"
  target_key_id = aws_kms_key.secrets_manager_key[0].key_id
}

# Secrets Manager Secret
resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  description             = var.secret_description
  kms_key_id              = var.create_kms_key ? aws_kms_key.secrets_manager_key[0].arn : var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days

  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region     = replica.value.region
      kms_key_id = replica.value.kms_key_id
    }
  }

  tags = merge(
    local.mandatory_tags,
    {
      Name    = var.secret_name
      Purpose = "Database credentials storage"
      Type    = var.secret_type
    }
  )
}

# Secret Version (initial value)
resource "aws_secretsmanager_secret_version" "this" {
  count = local.final_secret_string != null || var.secret_binary != null ? 1 : 0

  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = local.final_secret_string
  secret_binary = var.secret_binary

  lifecycle {
    ignore_changes = [secret_string, secret_binary]
  }
}

# Secret Policy for cross-service access
resource "aws_secretsmanager_secret_policy" "this" {
  count = var.secret_policy != null ? 1 : 0

  secret_arn          = aws_secretsmanager_secret.this.arn
  policy              = var.secret_policy
  block_public_policy = var.block_public_policy
}

# IAM Role for Lambda rotation function
resource "aws_iam_role" "rotation_lambda_role" {
  count = var.enable_automatic_rotation && var.create_rotation_lambda_role ? 1 : 0

  name        = "${var.secret_name}-rotation-lambda-role"
  description = "IAM role for Lambda rotation function for ${var.secret_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.secret_name}-rotation-lambda-role"
    }
  )
}

# IAM Policy for Lambda rotation function
resource "aws_iam_role_policy" "rotation_lambda_policy" {
  count = var.enable_automatic_rotation && var.create_rotation_lambda_role ? 1 : 0

  name = "${var.secret_name}-rotation-lambda-policy"
  role = aws_iam_role.rotation_lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Resource = aws_secretsmanager_secret.this.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*"
        ]
        Resource = var.create_kms_key ? aws_kms_key.secrets_manager_key[0].arn : var.kms_key_id
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Additional IAM policies for rotation function based on secret type
resource "aws_iam_role_policy" "rotation_lambda_rds_policy" {
  count = var.enable_automatic_rotation && var.create_rotation_lambda_role && var.secret_type == "rds" ? 1 : 0

  name = "${var.secret_name}-rotation-lambda-rds-policy"
  role = aws_iam_role.rotation_lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ModifyDBInstance",
          "rds:ModifyDBCluster"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "rotation_lambda_redshift_policy" {
  count = var.enable_automatic_rotation && var.create_rotation_lambda_role && var.secret_type == "redshift" ? 1 : 0

  name = "${var.secret_name}-rotation-lambda-redshift-policy"
  role = aws_iam_role.rotation_lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "redshift:DescribeClusters",
          "redshift:ModifyCluster"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "rotation_lambda_documentdb_policy" {
  count = var.enable_automatic_rotation && var.create_rotation_lambda_role && var.secret_type == "documentdb" ? 1 : 0

  name = "${var.secret_name}-rotation-lambda-documentdb-policy"
  role = aws_iam_role.rotation_lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBClusters",
          "rds:ModifyDBCluster"
        ]
        Resource = "*"
      }
    ]
  })
}

# VPC configuration for Lambda rotation function
resource "aws_iam_role_policy" "rotation_lambda_vpc_policy" {
  count = var.enable_automatic_rotation && var.create_rotation_lambda_role && var.rotation_lambda_vpc_config != null ? 1 : 0

  name = "${var.secret_name}-rotation-lambda-vpc-policy"
  role = aws_iam_role.rotation_lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:AttachNetworkInterface",
          "ec2:DetachNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

# Secret Rotation Configuration
resource "aws_secretsmanager_secret_rotation" "this" {
  count = var.enable_automatic_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.this.id
  rotation_lambda_arn = var.rotation_lambda_arn != null ? var.rotation_lambda_arn : (var.create_rotation_lambda_role ? aws_iam_role.rotation_lambda_role[0].arn : null)
  rotate_immediately  = var.rotate_immediately

  rotation_rules {
    automatically_after_days = var.rotation_days
  }

  depends_on = [
    aws_iam_role_policy.rotation_lambda_policy,
    aws_iam_role_policy.rotation_lambda_rds_policy,
    aws_iam_role_policy.rotation_lambda_redshift_policy,
    aws_iam_role_policy.rotation_lambda_documentdb_policy,
    aws_iam_role_policy.rotation_lambda_vpc_policy
  ]
}

# Cross-service access policies for common AWS services
resource "aws_secretsmanager_secret_policy" "lambda_access" {
  count = var.allow_lambda_access ? 1 : 0

  secret_arn = aws_secretsmanager_secret.this.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaAccess"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_secretsmanager_secret_policy" "ecs_access" {
  count = var.allow_ecs_access ? 1 : 0

  secret_arn = aws_secretsmanager_secret.this.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSAccess"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_secretsmanager_secret_policy" "rds_access" {
  count = var.allow_rds_access ? 1 : 0

  secret_arn = aws_secretsmanager_secret.this.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRDSAccess"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Cross-account access policy
resource "aws_secretsmanager_secret_policy" "cross_account_access" {
  count = length(var.cross_account_access) > 0 ? 1 : 0

  secret_arn = aws_secretsmanager_secret.this.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = [for account_id in var.cross_account_access : "arn:aws:iam::${account_id}:root"]
        }
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}

# Cross-role access policy
resource "aws_secretsmanager_secret_policy" "cross_role_access" {
  count = length(var.cross_role_access) > 0 ? 1 : 0

  secret_arn = aws_secretsmanager_secret.this.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossRoleAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.cross_role_access
        }
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}

# Additional service principals access policy
resource "aws_secretsmanager_secret_policy" "cross_service_access" {
  count = length(var.cross_service_principals) > 0 ? 1 : 0

  secret_arn = aws_secretsmanager_secret.this.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossServiceAccess"
        Effect = "Allow"
        Principal = {
          Service = var.cross_service_principals
        }
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
