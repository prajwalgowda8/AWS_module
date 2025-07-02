
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Security Group for OpenSearch
resource "aws_security_group" "opensearch" {
  name_prefix = "${var.domain_name}-opensearch-sg"
  vpc_id      = var.vpc_id
  description = "Security group for OpenSearch domain ${var.domain_name}"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
    description     = "HTTPS access from allowed security groups"
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
      Name = "${var.domain_name}-opensearch-sg"
    }
  )
}

# OpenSearch Domain
resource "aws_opensearch_domain" "this" {
  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = var.dedicated_master_enabled
    master_instance_type     = var.master_instance_type
    master_instance_count    = var.master_instance_count
    zone_awareness_enabled   = var.zone_awareness_enabled

    dynamic "zone_awareness_config" {
      for_each = var.zone_awareness_enabled ? [1] : []
      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_type = var.volume_type
    volume_size = var.volume_size
    iops        = var.volume_type == "io1" ? var.iops : null
  }

  encrypt_at_rest {
    enabled    = var.encrypt_at_rest
    kms_key_id = var.kms_key_id
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption
  }

  domain_endpoint_options {
    enforce_https       = var.enforce_https
    tls_security_policy = var.tls_security_policy
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.opensearch.id]
  }

  advanced_security_options {
    enabled                        = var.advanced_security_enabled
    anonymous_auth_enabled         = var.anonymous_auth_enabled
    internal_user_database_enabled = var.internal_user_database_enabled
    
    dynamic "master_user_options" {
      for_each = var.advanced_security_enabled && var.internal_user_database_enabled ? [1] : []
      content {
        master_user_name     = var.master_user_name
        master_user_password = var.master_user_password
      }
    }
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "INDEX_SLOW_LOGS"
    enabled                  = var.enable_slow_logs
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "SEARCH_SLOW_LOGS"
    enabled                  = var.enable_slow_logs
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "ES_APPLICATION_LOGS"
    enabled                  = var.enable_application_logs
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  access_policies = var.access_policies

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.domain_name
    }
  )

  depends_on = [aws_cloudwatch_log_group.opensearch_logs]
}

# CloudWatch Log Group for OpenSearch
resource "aws_cloudwatch_log_group" "opensearch_logs" {
  name              = "/aws/opensearch/domains/${var.domain_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.domain_name}-logs"
    }
  )
}
