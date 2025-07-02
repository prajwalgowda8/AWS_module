
# =============================================================================
# Compute Services Configuration
# File 2 of 5: EKS, Jump Servers, ECR, and Lambda resources
# =============================================================================

# Data sources to reference core infrastructure
data "aws_ssm_parameter" "project_config" {
  name = "/${var.project_name}/config/base"
}

locals {
  project_config = jsondecode(data.aws_ssm_parameter.project_config.value)
}

# =============================================================================
# Resource 1: Amazon EKS Cluster (sc-eks-demo)
# =============================================================================

module "eks" {
  source = "./eks"

  cluster_name = local.project_config.cluster_name
  kubernetes_version = "1.28"
  
  vpc_id = local.project_config.vpc_id
  subnet_ids = concat(
    local.project_config.public_subnet_ids,
    local.project_config.private_subnet_ids
  )
  private_subnet_ids = local.project_config.private_subnet_ids
  
  endpoint_private_access = true
  endpoint_public_access = true
  public_access_cidrs = ["0.0.0.0/0"]
  
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  # Node group configuration - 3 x m5.xlarge worker nodes
  capacity_type = "ON_DEMAND"
  instance_types = var.eks_node_instance_types
  ami_type = "AL2_x86_64"
  disk_size = 50
  
  desired_size = var.eks_node_desired_size
  max_size = var.eks_node_max_size
  min_size = var.eks_node_min_size
  max_unavailable = 1

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "Compute"
    Type      = "Kubernetes"
    Service   = "EKS"
  }

  depends_on = [data.aws_ssm_parameter.project_config]
}

# =============================================================================
# Resource 2: Jump Server Linux (t2.medium)
# =============================================================================

module "jump_server_linux" {
  source = "./jump_server"

  name_prefix = "${local.project_config.service_prefix}-linux"
  vpc_id = local.project_config.vpc_id
  
  create_linux_jump_server = true
  create_windows_jump_server = false
  
  linux_instance_type = "t2.medium"
  linux_subnet_id = local.project_config.public_subnet_ids[0]
  
  existing_key_pair_name = local.project_config.key_pair_name
  associate_public_ip = true
  create_elastic_ip = false
  
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]
  
  additional_linux_ports = [
    {
      port        = 8080
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.existing.cidr_block]
      description = "Application port access from VPC"
    },
    {
      port        = 9090
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.existing.cidr_block]
      description = "Monitoring port access from VPC"
    }
  ]
  
  additional_iam_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  ]

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "Compute"
    Type      = "JumpServer"
    OS        = "Linux"
    Service   = "EC2"
  }

  depends_on = [data.aws_ssm_parameter.project_config]
}

# =============================================================================
# Resource 3: Jump Server Windows (t3.large)
# =============================================================================

module "jump_server_windows" {
  source = "./jump_server"

  name_prefix = "${local.project_config.service_prefix}-windows"
  vpc_id = local.project_config.vpc_id
  
  create_linux_jump_server = false
  create_windows_jump_server = true
  
  windows_instance_type = "t3.large"
  windows_subnet_id = local.project_config.public_subnet_ids[1]
  
  existing_key_pair_name = local.project_config.key_pair_name
  associate_public_ip = true
  create_elastic_ip = false
  
  allowed_rdp_cidr_blocks = ["0.0.0.0/0"]
  
  additional_windows_ports = [
    {
      port        = 8080
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.existing.cidr_block]
      description = "Application port access from VPC"
    },
    {
      port        = 5985
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.existing.cidr_block]
      description = "WinRM HTTP access from VPC"
    },
    {
      port        = 5986
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.existing.cidr_block]
      description = "WinRM HTTPS access from VPC"
    }
  ]
  
  additional_iam_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  ]

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "Compute"
    Type      = "JumpServer"
    OS        = "Windows"
    Service   = "EC2"
  }

  depends_on = [data.aws_ssm_parameter.project_config]
}

# =============================================================================
# Resource 4: Amazon ECR (container registry)
# =============================================================================

module "ecr" {
  source = "./ecr"

  repository_name = "${local.project_config.service_prefix}-app-repo"
  image_tag_mutability = "MUTABLE"
  scan_on_push = true
  force_delete = true

  encryption_type = var.enable_encryption ? "KMS" : "AES256"
  
  enable_lifecycle_policy = true
  max_image_count = 10
  untagged_image_days = 7

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "ContainerRegistry"
    Service   = "ECR"
    Purpose   = "ApplicationImages"
  }
}

# =============================================================================
# Resource 5: AWS Lambda Function (sc-lambda-transcribeHandler-demo)
# =============================================================================

# Create placeholder Lambda deployment package
data "archive_file" "lambda_placeholder" {
  type        = "zip"
  output_path = "lambda_placeholder.zip"
  source {
    content = templatefile("${path.module}/lambda_function_template.py", {
      project_name = var.project_name
      environment  = var.environment
    })
    filename = "lambda_function.py"
  }
}

# Lambda function template file content
resource "local_file" "lambda_function_template" {
  content = <<-EOT
import json
import boto3
import os
import logging
import time
from typing import Dict, Any

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
transcribe_client = boto3.client('transcribe')
s3_client = boto3.client('s3')
secrets_client = boto3.client('secretsmanager')

def lambda_handler(event: Dict[str, Any], context) -> Dict[str, Any]:
    """
    Lambda function to handle transcription requests for Study Companion
    
    Args:
        event: Lambda event containing S3 object information or direct transcription request
        context: Lambda context object
        
    Returns:
        Dict containing status and response information
    """
    
    try:
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Environment variables
        project_name = os.environ.get('PROJECT_NAME', '${project_name}')
        environment = os.environ.get('ENVIRONMENT', '${environment}')
        
        logger.info(f"Processing request for project: {project_name}, environment: {environment}")
        
        # Handle S3 event trigger
        if 'Records' in event:
            return handle_s3_event(event['Records'])
        
        # Handle direct API call
        elif 'audio_file_uri' in event:
            return handle_direct_transcription(event)
        
        else:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'Invalid event format',
                    'message': 'Event must contain either S3 Records or audio_file_uri'
                })
            }
            
    except Exception as e:
        logger.error(f"Error processing transcription request: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }

def handle_s3_event(records: list) -> Dict[str, Any]:
    """Handle S3 event-triggered transcription"""
    
    results = []
    
    for record in records:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        
        # Only process audio files
        if not key.lower().endswith(('.mp3', '.wav', '.m4a', '.flac')):
            logger.info(f"Skipping non-audio file: {key}")
            continue
            
        audio_uri = f"s3://{bucket}/{key}"
        result = start_transcription_job(audio_uri, key)
        results.append(result)
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Processed {len(results)} audio files',
            'results': results
        })
    }

def handle_direct_transcription(event: Dict[str, Any]) -> Dict[str, Any]:
    """Handle direct transcription request"""
    
    audio_uri = event['audio_file_uri']
    job_name = event.get('job_name', f"transcription-{int(time.time())}")
    
    result = start_transcription_job(audio_uri, job_name)
    
    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }

def start_transcription_job(audio_uri: str, job_name: str) -> Dict[str, Any]:
    """Start AWS Transcribe job"""
    
    try:
        # Generate unique job name
        unique_job_name = f"{job_name.replace('/', '-').replace('.', '-')}-{int(time.time())}"
        
        # Start transcription job
        response = transcribe_client.start_transcription_job(
            TranscriptionJobName=unique_job_name,
            Media={'MediaFileUri': audio_uri},
            MediaFormat='mp3',  # Adjust based on file type
            LanguageCode='en-US',
            OutputBucketName=os.environ.get('OUTPUT_BUCKET'),
            Settings={
                'ShowSpeakerLabels': True,
                'MaxSpeakerLabels': 2
            }
        )
        
        logger.info(f"Started transcription job: {unique_job_name}")
        
        return {
            'job_name': unique_job_name,
            'status': 'STARTED',
            'audio_uri': audio_uri
        }
        
    except Exception as e:
        logger.error(f"Failed to start transcription job: {str(e)}")
        return {
            'error': str(e),
            'status': 'FAILED',
            'audio_uri': audio_uri
        }
EOT
  filename = "${path.module}/lambda_function_template.py"
}

module "lambda" {
  source = "./lambda"

  function_name = "${local.project_config.service_prefix}-lambda-transcribeHandler-${var.environment}"
  description = "Lambda function to handle transcription requests for Study Companion"
  
  runtime = var.lambda_runtime
  handler = "lambda_function.lambda_handler"
  memory_size = var.lambda_memory_size
  timeout = var.lambda_timeout
  
  filename = data.archive_file.lambda_placeholder.output_path
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256
  
  environment_variables = {
    PROJECT_NAME = var.project_name
    ENVIRONMENT = var.environment
    SECRETS_MANAGER_ARN = local.project_config.db_secrets_arn
    LOG_LEVEL = "INFO"
    OUTPUT_BUCKET = "${local.project_config.service_prefix}-s3-${var.environment}-${local.project_config.bucket_suffix}"
  }
  
  vpc_config = {
    vpc_id = local.project_config.vpc_id
    subnet_ids = local.project_config.private_subnet_ids
    security_group_ids = [local.project_config.lambda_sg_id]
  }
  
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/AmazonTranscribeFullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  mandatory_tags = local.mandatory_tags
  additional_tags = {
    Component = "Compute"
    Purpose   = "TranscriptionHandler"
    Service   = "Lambda"
  }

  depends_on = [
    data.aws_ssm_parameter.project_config,
    local_file.lambda_function_template
  ]
}

# =============================================================================
# Data Sources and Supporting Resources
# =============================================================================

# Data source for existing VPC (for CIDR block reference)
data "aws_vpc" "existing" {
  id = local.project_config.vpc_id
}

# Update project config with compute service outputs
resource "aws_ssm_parameter" "compute_config" {
  name  = "/${var.project_name}/config/compute"
  type  = "String"
  value = jsonencode({
    # EKS Configuration
    eks_cluster_id = module.eks.cluster_id
    eks_cluster_arn = module.eks.cluster_arn
    eks_cluster_endpoint = module.eks.cluster_endpoint
    eks_cluster_security_group_id = module.eks.cluster_security_group_id
    eks_cluster_version = module.eks.cluster_version
    eks_node_group_arn = module.eks.node_group_arn
    
    # Jump Servers
    linux_jump_server_id = module.jump_server_linux.linux_jump_server_id
    linux_jump_server_private_ip = module.jump_server_linux.linux_jump_server_private_ip
    linux_jump_server_public_ip = module.jump_server_linux.linux_jump_server_public_ip
    linux_security_group_id = module.jump_server_linux.linux_security_group_id
    
    windows_jump_server_id = module.jump_server_windows.windows_jump_server_id
    windows_jump_server_private_ip = module.jump_server_windows.windows_jump_server_private_ip
    windows_jump_server_public_ip = module.jump_server_windows.windows_jump_server_public_ip
    windows_security_group_id = module.jump_server_windows.windows_security_group_id
    
    # ECR
    ecr_repository_url = module.ecr.repository_url
    ecr_repository_arn = module.ecr.repository_arn
    ecr_registry_id = module.ecr.registry_id
    
    # Lambda
    lambda_function_arn = module.lambda.function_arn
    lambda_function_name = module.lambda.function_name
    lambda_invoke_arn = module.lambda.invoke_arn
    lambda_role_arn = module.lambda.role_arn
    
    # VPC Information
    vpc_cidr_block = data.aws_vpc.existing.cidr_block
  })

  tags = merge(local.mandatory_tags, {
    Name      = "${var.project_name}-compute-config"
    Component = "Configuration"
    Purpose   = "CrossFileReference"
  })

  depends_on = [
    module.eks,
    module.jump_server_linux,
    module.jump_server_windows,
    module.ecr,
    module.lambda
  ]
}

# CloudWatch Log Groups for compute services
resource "aws_cloudwatch_log_group" "compute_logs" {
  name              = "/aws/${var.project_name}/${var.environment}/compute"
  retention_in_days = var.log_retention_days

  tags = merge(local.mandatory_tags, {
    Name      = "${local.project_config.service_prefix}-compute-logs-${var.environment}"
    Component = "Monitoring"
    Purpose   = "ComputeLogging"
    Service   = "CloudWatch"
  })
}
