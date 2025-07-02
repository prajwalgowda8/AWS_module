
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM Role for Glue
resource "aws_iam_role" "glue_role" {
  name = "${var.database_name}-glue-role"

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
    var.mandatory_tags,
    var.additional_tags,
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
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
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
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.database_name
    }
  )
}

# Glue Jobs
resource "aws_glue_job" "jobs" {
  for_each = var.glue_jobs

  name         = "${var.database_name}-${each.key}"
  description  = each.value.description
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = each.value.glue_version

  command {
    script_location = each.value.script_location
    python_version  = each.value.python_version
  }

  default_arguments = merge(
    each.value.default_arguments,
    {
      "--job-bookmark-option" = "job-bookmark-enable"
      "--enable-metrics"      = ""
    }
  )

  execution_property {
    max_concurrent_runs = each.value.max_concurrent_runs
  }

  max_retries = each.value.max_retries
  timeout     = each.value.timeout

  worker_type       = each.value.worker_type
  number_of_workers = each.value.number_of_workers

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.database_name}-${each.key}"
    }
  )
}
