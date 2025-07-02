
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      contact_group                  = var.contact_group
      contact_name                   = var.contact_name
      cost_bucket                    = var.cost_bucket
      data_owner                     = var.data_owner
      display_name                   = var.display_name
      environment                    = var.environment
      has_public_ip                  = var.has_public_ip
      has_unisys_network_connection  = var.has_unisys_network_connection
      service_line                   = var.service_line
      project                        = var.project_name
      managed_by                     = "terraform"
    }
  }
}

locals {
  module_source = "git::https://github.com/prajwalgowda8/AWS_module.git//"
}
