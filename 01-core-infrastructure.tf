
# =============================================================================
# Core Infrastructure Configuration
# File 1 of 5: Foundation resources for Study Companion infrastructure
# =============================================================================

# Local values for configuration
locals {
  mandatory_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = "DevOps Team"
    ManagedBy   = "Terraform"
  }

  service_prefix = "sc"
  cluster_name = "${local.service_prefix}-eks-${var.environment}"
}

# =============================================================================
# Resource 1: IAM Roles & Policies (Shared across services)
# =============================================================================

# EKS Cluster Service Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.service_prefix}-eks-cluster-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-eks-cluster-role-${var.environment}"
    Component = "IAM"
    Service   = "EKS"
  })
}

# EKS Node Group Role
resource "aws_iam_role" "eks_node_role" {
  name = "${local.service_prefix}-eks-node-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-eks-node-role-${var.environment}"
    Component = "IAM"
    Service   = "EKS"
  })
}

# Lambda Execution Role
resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.service_prefix}-lambda-execution-role-${var.environment}"

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

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-lambda-execution-role-${var.environment}"
    Component = "IAM"
    Service   = "Lambda"
  })
}

# Glue Service Role
resource "aws_iam_role" "glue_service_role" {
  name = "${local.service_prefix}-glue-service-role-${var.environment}"

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

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-glue-service-role-${var.environment}"
    Component = "IAM"
    Service   = "Glue"
  })
}

# Attach required policies to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Attach required policies to EKS Node Role
resource "aws_iam_role_policy_attachment" "eks_node_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# Attach required policies to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

# Attach required policies to Glue Role
resource "aws_iam_role_policy_attachment" "glue_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.glue_service_role.name
}

# =============================================================================
# Resource 2: Security Groups (Application-level, using existing VPC)
# =============================================================================

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "${local.service_prefix}-eks-cluster-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for EKS cluster control plane"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access to EKS API server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-eks-cluster-sg-${var.environment}"
    Component = "Security"
    Service   = "EKS"
  })
}

# Security Group for EKS Worker Nodes
resource "aws_security_group" "eks_node_sg" {
  name_prefix = "${local.service_prefix}-eks-node-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for EKS worker nodes"

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
    description     = "Allow cluster to communicate with nodes"
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
    description = "Allow nodes to communicate with each other"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-eks-node-sg-${var.environment}"
    Component = "Security"
    Service   = "EKS"
  })
}

# Security Group for RDS Database
resource "aws_security_group" "database_sg" {
  name_prefix = "${local.service_prefix}-database-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for RDS PostgreSQL database"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [
      aws_security_group.eks_node_sg.id,
      aws_security_group.lambda_sg.id
    ]
    description = "PostgreSQL access from EKS nodes and Lambda"
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
    description = "PostgreSQL access within security group"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-database-sg-${var.environment}"
    Component = "Security"
    Service   = "RDS"
  })
}

# Security Group for Lambda Functions
resource "aws_security_group" "lambda_sg" {
  name_prefix = "${local.service_prefix}-lambda-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for Lambda functions"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-lambda-sg-${var.environment}"
    Component = "Security"
    Service   = "Lambda"
  })
}

# Security Group for OpenSearch
resource "aws_security_group" "opensearch_sg" {
  name_prefix = "${local.service_prefix}-opensearch-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for OpenSearch cluster"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [
      aws_security_group.eks_node_sg.id,
      aws_security_group.lambda_sg.id
    ]
    description = "HTTPS access from EKS nodes and Lambda"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-opensearch-sg-${var.environment}"
    Component = "Security"
    Service   = "OpenSearch"
  })
}

# =============================================================================
# Resource 3: AWS Secrets Manager (sc-secrets-dbcreds-demo)
# =============================================================================

module "secrets_manager" {
  source = "./secrets_manager"

  secret_name = "${local.service_prefix}-secrets-dbcreds-${var.environment}"
  secret_description = "Database credentials for Study Companion application"
  
  create_kms_key = var.enable_encryption
  enable_automatic_rotation = false
  recovery_window_in_days = 7

  database_secret_template = true
  allow_lambda_access = true
  allow_ecs_access = true
  allow_rds_access = true

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "Security"
    Purpose   = "DatabaseCredentials"
    Service   = "SecretsManager"
  }
}

# =============================================================================
# Resource 4: Key Pairs (for Jump Servers)
# =============================================================================

# Generate SSH key pair for jump servers
resource "tls_private_key" "jump_server_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  lifecycle {
    ignore_changes = [algorithm, rsa_bits]
  }
}

# AWS Key Pair for jump servers
resource "aws_key_pair" "jump_server_key_pair" {
  key_name   = "${local.service_prefix}-jump-server-key-${var.environment}"
  public_key = tls_private_key.jump_server_key.public_key_openssh

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-jump-server-key-${var.environment}"
    Component = "Security"
    Purpose   = "JumpServerAccess"
  })
}

# Store private key in Secrets Manager for secure access
resource "aws_secretsmanager_secret" "jump_server_private_key" {
  name        = "${local.service_prefix}-jump-server-private-key-${var.environment}"
  description = "Private key for jump server access"
  
  recovery_window_in_days = 7

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-jump-server-private-key-${var.environment}"
    Component = "Security"
    Purpose   = "JumpServerPrivateKey"
  })
}

resource "aws_secretsmanager_secret_version" "jump_server_private_key" {
  secret_id     = aws_secretsmanager_secret.jump_server_private_key.id
  secret_string = jsonencode({
    private_key = tls_private_key.jump_server_key.private_key_pem
    public_key  = tls_private_key.jump_server_key.public_key_openssh
    key_name    = aws_key_pair.jump_server_key_pair.key_name
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# =============================================================================
# Resource 5: Base Tagging & Common Resources
# =============================================================================

# Random ID for unique resource naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# SSM Parameter for project configuration (shared across files)
resource "aws_ssm_parameter" "project_config" {
  name  = "/${var.project_name}/config/base"
  type  = "String"
  value = jsonencode({
    # Project Information
    project_name       = var.project_name
    environment        = var.environment
    service_prefix     = local.service_prefix
    cluster_name       = local.cluster_name
    
    # Network Configuration
    vpc_id             = var.vpc_id
    public_subnet_ids  = var.public_subnet_ids
    private_subnet_ids = var.private_subnet_ids
    availability_zones = var.availability_zones
    
    # Security Groups
    eks_cluster_sg_id  = aws_security_group.eks_cluster_sg.id
    eks_node_sg_id     = aws_security_group.eks_node_sg.id
    database_sg_id     = aws_security_group.database_sg.id
    lambda_sg_id       = aws_security_group.lambda_sg.id
    opensearch_sg_id   = aws_security_group.opensearch_sg.id
    
    # IAM Roles
    eks_cluster_role_arn = aws_iam_role.eks_cluster_role.arn
    eks_node_role_arn    = aws_iam_role.eks_node_role.arn
    lambda_role_arn      = aws_iam_role.lambda_execution_role.arn
    glue_role_arn        = aws_iam_role.glue_service_role.arn
    
    # Secrets Manager
    db_secrets_arn = module.secrets_manager.secret_arn
    
    # Key Pair
    key_pair_name = aws_key_pair.jump_server_key_pair.key_name
    
    # Common Resources
    bucket_suffix = random_id.bucket_suffix.hex
  })

  tags = merge(local.mandatory_tags, {
    Name      = "${var.project_name}-base-config"
    Component = "Configuration"
    Purpose   = "CrossFileReference"
  })
}

# CloudWatch Log Group for centralized logging
resource "aws_cloudwatch_log_group" "central_logs" {
  name              = "/aws/${var.project_name}/${var.environment}/central"
  retention_in_days = var.log_retention_days
  
  kms_key_id = var.enable_encryption ? aws_kms_key.central_logging[0].arn : null

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-central-logs-${var.environment}"
    Component = "Monitoring"
    Purpose   = "CentralLogging"
  })
}

# KMS Key for central logging (conditional)
resource "aws_kms_key" "central_logging" {
  count = var.enable_encryption ? 1 : 0

  description             = "KMS key for central logging encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

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
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.mandatory_tags, {
    Name      = "${local.service_prefix}-central-logging-key-${var.environment}"
    Component = "Security"
    Purpose   = "LoggingEncryption"
  })
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# KMS Alias for easier identification
resource "aws_kms_alias" "central_logging" {
  count = var.enable_encryption ? 1 : 0

  name          = "alias/${local.service_prefix}-central-logging-${var.environment}"
  target_key_id = aws_kms_key.central_logging[0].key_id
}
