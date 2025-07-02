
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

# CloudWatch Log Group for Glue jobs
resource "aws_cloudwatch_log_group" "glue_logs" {
  name              = "/aws-glue/jobs/${var.database_name}"
  retention_in_days = var.log_group_retention_days

  tags = merge(
    local.mandatory_tags,
    {
      Name = "/aws-glue/jobs/${var.database_name}"
    }
  )
}

# IAM Role for Glue
resource "aws_iam_role" "glue_role" {
  name        = "${var.database_name}-glue-role"
  description = "IAM role for AWS Glue service for ${var.database_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.database_name}-glue-role"
    }
  )
}

# Attach Glue service role policy
resource "aws_iam_role_policy_attachment" "glue_service_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.glue_role.name
}

# Custom policy for S3 access
resource "aws_iam_role_policy" "glue_s3_policy" {
  name = "${var.database_name}-glue-s3-policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# Custom policy for CloudWatch Logs
resource "aws_iam_role_policy" "glue_logs_policy" {
  name = "${var.database_name}-glue-logs-policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          aws_cloudwatch_log_group.glue_logs.arn,
          "${aws_cloudwatch_log_group.glue_logs.arn}:*"
        ]
      }
    ]
  })
}

# Glue Catalog Database
resource "aws_glue_catalog_database" "this" {
  name        = var.database_name
  description = "Glue catalog database for ${var.database_name}"

  tags = merge(
    local.mandatory_tags,
    {
      Name = var.database_name
    }
  )
}

# Glue Connections
resource "aws_glue_connection" "connections" {
  for_each = var.connections

  name            = "${var.database_name}-${each.key}"
  description     = each.value.description
  connection_type = each.value.connection_type

  connection_properties = each.value.connection_properties

  dynamic "physical_connection_requirements" {
    for_each = each.value.physical_connection_requirements != null ? [each.value.physical_connection_requirements] : []
    content {
      availability_zone      = physical_connection_requirements.value.availability_zone
      security_group_id_list = physical_connection_requirements.value.security_group_id_list
      subnet_id              = physical_connection_requirements.value.subnet_id
    }
  }

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.database_name}-${each.key}"
    }
  )
}

# Glue Jobs
resource "aws_glue_job" "jobs" {
  for_each = var.glue_jobs

  name         = "${var.database_name}-${each.key}"
  description  = each.value.description
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = var.glue_version

  command {
    script_location = each.value.script_location
    python_version  = each.value.python_version
  }

  default_arguments = merge(
    each.value.default_arguments,
    {
      "--job-bookmark-option"           = var.enable_job_bookmarks ? "job-bookmark-enable" : "job-bookmark-disable"
      "--enable-metrics"                = var.enable_metrics ? "" : null
      "--enable-continuous-cloudwatch-log" = var.enable_continuous_logging ? "true" : "false"
      "--continuous-log-logGroup"       = aws_cloudwatch_log_group.glue_logs.name
    }
  )

  execution_property {
    max_concurrent_runs = each.value.max_concurrent_runs
  }

  max_retries = each.value.max_retries
  timeout     = each.value.timeout

  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers

  connections = length(each.value.connections) > 0 ? each.value.connections : null

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.database_name}-${each.key}"
    }
  )
}

# Glue Crawlers
resource "aws_glue_crawler" "crawlers" {
  for_each = var.crawlers

  name          = "${var.database_name}-${each.key}"
  description   = each.value.description
  database_name = aws_glue_catalog_database.this.name
  role          = aws_iam_role.glue_role.arn
  schedule      = each.value.schedule
  table_prefix  = each.value.table_prefix

  dynamic "s3_target" {
    for_each = each.value.s3_targets
    content {
      path       = s3_target.value.path
      exclusions = s3_target.value.exclusions
    }
  }

  dynamic "jdbc_target" {
    for_each = each.value.jdbc_targets
    content {
      connection_name = jdbc_target.value.connection_name
      path            = jdbc_target.value.path
      exclusions      = jdbc_target.value.exclusions
    }
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }

  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.database_name}-${each.key}"
    }
  )
}

# Note: Glue notebook will be uploaded manually
# The Glue notebook/development endpoint configuration is not included
# in this Terraform module as notebooks are typically managed manually
# through the AWS Glue console or uploaded via separate processes.
