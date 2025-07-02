
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
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
    var.mandatory_tags,
    var.additional_tags,
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

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.db_identifier}-subnet-group"
    }
  )
}

# DB Parameter Group
resource "aws_db_parameter_group" "postgres" {
  family = var.parameter_group_family
  name   = "${var.db_identifier}-params"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.db_identifier}-params"
    }
  )
}

# Security Group for RDS
resource "aws_security_group" "postgres" {
  name_prefix = "${var.db_identifier}-rds-sg"
  vpc_id      = var.vpc_id
  description = "Security group for RDS PostgreSQL ${var.db_identifier}"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
    description     = "PostgreSQL access from allowed security groups"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.db_identifier}-rds-sg"
    }
  )
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
  monitoring_role_arn = var.monitoring_role_arn
  
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
  
  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.db_identifier
    }
  )
}
