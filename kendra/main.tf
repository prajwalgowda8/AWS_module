
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

# Fix the JWT token configuration in user_token_configurations
resource "aws_kendra_index" "this" {
  # ... other configuration ...

  user_token_configurations {
    jwt_token_type_configuration {
      # Fix the attribute name from secret_manager_arn to secrets_manager_arn
      secrets_manager_arn        = var.database_credentials_secret_arn
      key_location              = "URL"
      url                       = var.jwt_token_url
      user_name_attribute_field = "preferred_username"
      group_attribute_field     = "groups"
      issuer                    = var.jwt_issuer
      claim_regex              = var.jwt_claim_regex
    }
  }

  # Fix the tags attribute by using the correct merge syntax
  tags = merge(
    local.mandatory_tags,
    {
      Name = "${var.service_name}-kendra-index"
    }
  )
}
