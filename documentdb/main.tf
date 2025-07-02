
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Random password for DocumentDB
resource "random_password" "docdb_password" {
  length  = 16
  special = true
}

# Secrets Manager secret for DocumentDB credentials
resource "aws_secretsmanager_secret" "docdb_credentials" {
  name        = "${var.cluster_identifier}-credentials"
  description = "DocumentDB credentials for ${var.cluster_identifier}"
  
  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.cluster_identifier}-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "docdb_credentials" {
  secret_id = aws_secretsmanager_secret.docdb_credentials.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.docdb_password.result
    engine   = "docdb"
    host     = aws_docdb_cluster.this.endpoint
    port     = aws_docdb_cluster.this.port
  })
}

# DB Subnet Group
resource "aws_docdb_subnet_group" "this" {
  name       = "${var.cluster_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.cluster_identifier}-subnet-group"
    }
  )
}

# Security Group for DocumentDB
resource "aws_security_group" "docdb" {
  name_prefix = "${var.cluster_identifier}-docdb-sg"
  vpc_id      = var.vpc_id
  description = "Security group for DocumentDB cluster ${var.cluster_identifier}"

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
    description     = "DocumentDB access from allowed security groups"
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
      Name = "${var.cluster_identifier}-docdb-sg"
    }
  )
}

# DocumentDB Cluster
resource "aws_docdb_cluster" "this" {
  cluster_identifier      = var.cluster_identifier
  engine                 = "docdb"
  engine_version         = var.engine_version
  master_username        = var.master_username
  master_password        = random_password.docdb_password.result
  
  # Network configuration
  db_subnet_group_name   = aws_docdb_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.docdb.id]
  port                   = 27017
  
  # Backup configuration
  backup_retention_period   = var.backup_retention_period
  preferred_backup_window   = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  
  # Security
  storage_encrypted = var.storage_encrypted
  kms_key_id       = var.kms_key_id
  
  # High availability
  availability_zones = var.availability_zones
  
  # Deletion protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.cluster_identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # CloudWatch logs
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  # Auto minor version upgrade
  apply_immediately = var.apply_immediately
  
  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.cluster_identifier
    }
  )
}

# DocumentDB Cluster Instances
resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-${count.index}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.instance_class
  
  # Performance Insights
  enable_performance_insights     = var.enable_performance_insights
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  
  # Maintenance
  preferred_maintenance_window = var.preferred_maintenance_window
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  
  # Promotion tier for failover
  promotion_tier = count.index
  
  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.cluster_identifier}-${count.index}"
    }
  )
}
