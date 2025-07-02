
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
}

# Random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Secrets Manager secret for database credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.db_identifier}-credentials"
  description = "Database credentials for ${var.db_identifier}"
  
  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.db_identifier}-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.postgres.endpoint
    port     = aws_db_instance.postgres.port
    dbname   = var.db_name
  })
}

# DB Subnet Group
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  description = "DB subnet group for ${var.db_identifier}"

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.db_identifier}-subnet-group"
    }
  )
}

# DB Parameter Group
resource "aws_db_parameter_group" "postgres" {
  family      = var.parameter_group_family
  name        = "${var.db_identifier}-params"
  description = "DB parameter group for ${var.db_identifier}"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.db_identifier}-params"
    }
  )
}

# Security Group for RDS (self-referenced for port 5432)
resource "aws_security_group" "postgres" {
  name_prefix = "${var.db_identifier}-rds-sg"
  vpc_id      = var.vpc_id
  description = "Security group for RDS PostgreSQL ${var.db_identifier}"

  # Self-referenced ingress rule for PostgreSQL port 5432
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    self      = true
    description = "PostgreSQL access from same security group"
  }

  # Allow ingress from within the VPC CIDR (optional - can be removed if only self-reference is needed)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "PostgreSQL access from VPC CIDR"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.db_identifier}-rds-sg"
    }
  )
}

# Enhanced Monitoring IAM Role (if monitoring is enabled)
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.db_identifier}-rds-enhanced-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.db_identifier}-rds-enhanced-monitoring"
    }
  )
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  identifier = var.db_identifier
  
  # Engine configuration
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  # Storage configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id           = var.kms_key_id
  
  # Database configuration
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = 5432
  
  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  publicly_accessible    = var.publicly_accessible
  
  # Backup configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  # High availability
  multi_az = var.multi_az
  
  # Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : var.monitoring_role_arn
  
  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  
  # Parameter and option groups
  parameter_group_name = aws_db_parameter_group.postgres.name
  
  # Deletion protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.db_identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # CloudWatch logs
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  # Auto minor version upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  
  # Copy tags to snapshots
  copy_tags_to_snapshot = true
  
  tags = merge(
    local.mandatory_tags,
    {
      Name = var.db_identifier
    }
  )
}
