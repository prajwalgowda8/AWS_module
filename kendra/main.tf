
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# CloudWatch Log Group for Kendra
resource "aws_cloudwatch_log_group" "kendra_logs" {
  name              = "/aws/kendra/${var.index_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.index_name}-kendra-logs"
    }
  )
}

# IAM Role for Kendra Index
resource "aws_iam_role" "kendra_index_role" {
  name = "${var.index_name}-kendra-index-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kendra.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.index_name}-kendra-index-role"
    }
  )
}

# IAM Policy for Kendra Index CloudWatch access
resource "aws_iam_role_policy" "kendra_index_cloudwatch_policy" {
  name = "${var.index_name}-kendra-index-cloudwatch-policy"
  role = aws_iam_role.kendra_index_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "AWS/Kendra"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/kendra/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogStreams",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/kendra/*:log-stream:*"
      }
    ]
  })
}

# Kendra Index
resource "aws_kendra_index" "this" {
  name     = var.index_name
  role_arn = aws_iam_role.kendra_index_role.arn
  edition  = var.index_edition

  description = var.index_description

  dynamic "capacity_units" {
    for_each = var.capacity_units != null ? [var.capacity_units] : []
    content {
      query_capacity_units   = capacity_units.value.query_capacity_units
      storage_capacity_units = capacity_units.value.storage_capacity_units
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.kms_key_id != null ? [1] : []
    content {
      kms_key_id = var.kms_key_id
    }
  }

  user_context_policy = var.user_context_policy

  dynamic "user_group_resolution_configuration" {
    for_each = var.user_group_resolution_mode != null ? [1] : []
    content {
      user_group_resolution_mode = var.user_group_resolution_mode
    }
  }

  dynamic "user_token_configurations" {
    for_each = var.user_token_configurations
    content {
      dynamic "json_token_type_configuration" {
        for_each = user_token_configurations.value.json_token_type_configuration != null ? [user_token_configurations.value.json_token_type_configuration] : []
        content {
          user_name_attribute_field = json_token_type_configuration.value.user_name_attribute_field
          group_attribute_field     = json_token_type_configuration.value.group_attribute_field
        }
      }

      dynamic "jwt_token_type_configuration" {
        for_each = user_token_configurations.value.jwt_token_type_configuration != null ? [user_token_configurations.value.jwt_token_type_configuration] : []
        content {
          key_location                = jwt_token_type_configuration.value.key_location
          url                        = jwt_token_type_configuration.value.url
          secret_manager_arn         = jwt_token_type_configuration.value.secret_manager_arn
          user_name_attribute_field  = jwt_token_type_configuration.value.user_name_attribute_field
          group_attribute_field      = jwt_token_type_configuration.value.group_attribute_field
          issuer                     = jwt_token_type_configuration.value.issuer
          claim_regex                = jwt_token_type_configuration.value.claim_regex
        }
      }
    }
  }

  dynamic "document_metadata_configuration_updates" {
    for_each = var.document_metadata_configurations
    content {
      name = document_metadata_configuration_updates.value.name
      type = document_metadata_configuration_updates.value.type

      dynamic "relevance" {
        for_each = document_metadata_configuration_updates.value.relevance != null ? [document_metadata_configuration_updates.value.relevance] : []
        content {
          importance    = relevance.value.importance
          freshness     = relevance.value.freshness
          rank_order    = relevance.value.rank_order
          duration      = relevance.value.duration
          values_importance_map = relevance.value.values_importance_map
        }
      }

      dynamic "search" {
        for_each = document_metadata_configuration_updates.value.search != null ? [document_metadata_configuration_updates.value.search] : []
        content {
          facetable   = search.value.facetable
          searchable  = search.value.searchable
          displayable = search.value.displayable
          sortable    = search.value.sortable
        }
      }
    }
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.index_name
    }
  )

  depends_on = [
    aws_iam_role_policy.kendra_index_cloudwatch_policy,
    aws_cloudwatch_log_group.kendra_logs
  ]
}

# IAM Role for S3 Data Source
resource "aws_iam_role" "s3_data_source_role" {
  count = var.create_s3_data_source ? 1 : 0
  name  = "${var.index_name}-s3-data-source-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kendra.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.index_name}-s3-data-source-role"
    }
  )
}

# IAM Policy for S3 Data Source
resource "aws_iam_role_policy" "s3_data_source_policy" {
  count = var.create_s3_data_source ? 1 : 0
  name  = "${var.index_name}-s3-data-source-policy"
  role  = aws_iam_role.s3_data_source_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          for bucket_arn in var.s3_bucket_arns :
          "${bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = var.s3_bucket_arns
      },
      {
        Effect = "Allow"
        Action = [
          "kendra:BatchPutDocument",
          "kendra:BatchDeleteDocument"
        ]
        Resource = aws_kendra_index.this.arn
      }
    ]
  })
}

# S3 Data Source
resource "aws_kendra_data_source" "s3_data_source" {
  count = var.create_s3_data_source ? 1 : 0

  index_id = aws_kendra_index.this.id
  name     = "${var.index_name}-s3-data-source"
  type     = "S3"
  role_arn = aws_iam_role.s3_data_source_role[0].arn

  description   = var.s3_data_source_description
  language_code = var.language_code
  schedule      = var.s3_data_source_schedule

  configuration {
    s3_configuration {
      bucket_name = var.s3_data_source_bucket_name

      dynamic "inclusion_prefixes" {
        for_each = var.s3_inclusion_prefixes != null ? [var.s3_inclusion_prefixes] : []
        content {
          inclusion_prefixes = inclusion_prefixes.value
        }
      }

      dynamic "exclusion_patterns" {
        for_each = var.s3_exclusion_patterns != null ? [var.s3_exclusion_patterns] : []
        content {
          exclusion_patterns = exclusion_patterns.value
        }
      }

      dynamic "documents_metadata_configuration" {
        for_each = var.s3_documents_metadata_configuration != null ? [var.s3_documents_metadata_configuration] : []
        content {
          s3_prefix = documents_metadata_configuration.value.s3_prefix
        }
      }

      dynamic "access_control_list_configuration" {
        for_each = var.s3_access_control_list_configuration != null ? [var.s3_access_control_list_configuration] : []
        content {
          key_path = access_control_list_configuration.value.key_path
        }
      }
    }
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.index_name}-s3-data-source"
    }
  )

  depends_on = [aws_iam_role_policy.s3_data_source_policy]
}

# Custom Data Sources
resource "aws_kendra_data_source" "custom_data_sources" {
  for_each = var.custom_data_sources

  index_id = aws_kendra_index.this.id
  name     = each.value.name
  type     = each.value.type
  role_arn = each.value.role_arn

  description   = each.value.description
  language_code = each.value.language_code
  schedule      = each.value.schedule

  dynamic "configuration" {
    for_each = each.value.configuration != null ? [each.value.configuration] : []
    content {
      # Configuration varies by data source type
      # This is a flexible block that can accommodate different data source types
    }
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    each.value.tags,
    {
      Name = each.value.name
    }
  )
}

# FAQ Data Source
resource "aws_kendra_faq" "faqs" {
  for_each = var.faqs

  index_id = aws_kendra_index.this.id
  name     = each.value.name
  role_arn = each.value.role_arn

  description   = each.value.description
  file_format   = each.value.file_format
  language_code = each.value.language_code

  s3_path {
    bucket = each.value.s3_bucket
    key    = each.value.s3_key
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    each.value.tags,
    {
      Name = each.value.name
    }
  )
}

# Thesaurus
resource "aws_kendra_thesaurus" "thesaurus" {
  for_each = var.thesaurus_configurations

  index_id = aws_kendra_index.this.id
  name     = each.value.name
  role_arn = each.value.role_arn

  description = each.value.description

  source_s3_path {
    bucket = each.value.s3_bucket
    key    = each.value.s3_key
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    each.value.tags,
    {
      Name = each.value.name
    }
  )
}

# Query Suggestions Block List
resource "aws_kendra_query_suggestions_block_list" "block_lists" {
  for_each = var.query_suggestions_block_lists

  index_id = aws_kendra_index.this.id
  name     = each.value.name
  role_arn = each.value.role_arn

  description = each.value.description

  source_s3_path {
    bucket = each.value.s3_bucket
    key    = each.value.s3_key
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    each.value.tags,
    {
      Name = each.value.name
    }
  )
}

# Kendra Experience (Search Interface)
resource "aws_kendra_experience" "search_experience" {
  count = var.create_search_experience ? 1 : 0

  index_id = aws_kendra_index.this.id
  name     = "${var.index_name}-search-experience"
  role_arn = var.search_experience_role_arn != null ? var.search_experience_role_arn : aws_iam_role.search_experience_role[0].arn

  description = var.search_experience_description

  dynamic "configuration" {
    for_each = var.search_experience_configuration != null ? [var.search_experience_configuration] : []
    content {
      dynamic "content_source_configuration" {
        for_each = configuration.value.content_source_configuration != null ? [configuration.value.content_source_configuration] : []
        content {
          data_source_ids   = content_source_configuration.value.data_source_ids
          faq_ids          = content_source_configuration.value.faq_ids
          direct_put_content = content_source_configuration.value.direct_put_content
        }
      }

      dynamic "user_identity_configuration" {
        for_each = configuration.value.user_identity_configuration != null ? [configuration.value.user_identity_configuration] : []
        content {
          identity_attribute_name = user_identity_configuration.value.identity_attribute_name
        }
      }
    }
  }

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.index_name}-search-experience"
    }
  )
}

# IAM Role for Search Experience
resource "aws_iam_role" "search_experience_role" {
  count = var.create_search_experience && var.search_experience_role_arn == null ? 1 : 0
  name  = "${var.index_name}-search-experience-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kendra.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.index_name}-search-experience-role"
    }
  )
}

# IAM Policy for Search Experience
resource "aws_iam_role_policy" "search_experience_policy" {
  count = var.create_search_experience && var.search_experience_role_arn == null ? 1 : 0
  name  = "${var.index_name}-search-experience-policy"
  role  = aws_iam_role.search_experience_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kendra:Query",
          "kendra:DescribeIndex",
          "kendra:ListDataSources",
          "kendra:ListFaqs",
          "kendra:GetQuerySuggestions",
          "kendra:SubmitFeedback"
        ]
        Resource = aws_kendra_index.this.arn
      }
    ]
  })
}

# IAM Role for Lambda integration
resource "aws_iam_role" "lambda_kendra_role" {
  count = var.create_lambda_integration_role ? 1 : 0
  name  = "${var.index_name}-lambda-kendra-role"

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
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = "${var.index_name}-lambda-kendra-role"
    }
  )
}

# IAM Policy for Lambda Kendra access
resource "aws_iam_role_policy" "lambda_kendra_policy" {
  count = var.create_lambda_integration_role ? 1 : 0
  name  = "${var.index_name}-lambda-kendra-policy"
  role  = aws_iam_role.lambda_kendra_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kendra:Query",
          "kendra:Retrieve",
          "kendra:SubmitFeedback",
          "kendra:GetQuerySuggestions",
          "kendra:DescribeIndex",
          "kendra:ListDataSources",
          "kendra:ListFaqs"
        ]
        Resource = aws_kendra_index.this.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  count      = var.create_lambda_integration_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_kendra_role[0].name
}
