
# AWS Infrastructure

This Terraform configuration creates a complete AWS infrastructure stack using modular components with mandatory tagging compliance.

## Architecture Overview

This infrastructure includes:

- **EKS Cluster**: Kubernetes cluster with managed node groups
- **RDS PostgreSQL**: Managed database with encryption and monitoring
- **S3 Bucket**: Secure storage with encryption and versioning
- **Lambda Function**: Serverless compute with VPC integration
- **Glue**: Data catalog and ETL jobs
- **Step Functions**: Workflow orchestration
- **OpenSearch**: Search and analytics engine
- **Kendra**: Intelligent search service
- **ECR**: Container registry
- **SES**: Email service
- **Bedrock**: AI/ML model access
- **Secrets Manager**: Secure credential storage
- **CloudWatch**: Monitoring and logging

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0 installed
3. Existing VPC and subnets (IDs to be provided in terraform.tfvars)

## Mandatory Tagging

All resources are created with mandatory tags as required by the organization:

- `contactGroup`: Contact group for the resources
- `contactName`: Contact name for the resources
- `costBucket`: Cost bucket for the resources
- `dataOwner`: Data owner for the resources
- `displayName`: Display name for the resources
- `environment`: Environment for the resources
- `hasPublicIP`: Whether the resources have public IP
- `hasUnisysNetworkConnection`: Whether the resources have Unisys network connection
- `serviceLine`: Service line for the resources

## Usage

1. Update `terraform.tfvars` with your specific values:
   ```hcl
   vpc_id             = "vpc-xxxxxxxxx"
   private_subnet_ids = ["subnet-xxxxxxxxx", "subnet-yyyyyyyyy"]
   public_subnet_ids  = ["subnet-zzzzzzzzz", "subnet-aaaaaaaaa"]
   
   # Update mandatory tags
   contact_group = "Your Team"
   contact_name  = "Your Name"
   # ... other mandatory tags
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Plan the deployment:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Module Structure

Each AWS service is implemented as a separate module in the parent directory:
- `../eks/` - EKS cluster and node groups
- `../rds_postgres/` - PostgreSQL RDS instance
- `../s3_bucket/` - S3 bucket with security configurations
- `../lambda/` - Lambda function with IAM roles
- `../glue/` - Glue catalog and jobs
- `../step_functions/` - Step Functions state machines
- `../opensearch/` - OpenSearch domain
- `../kendra/` - Kendra search index
- `../ecr/` - ECR repository
- `../ses/` - SES email service
- `../bedrock/` - Bedrock AI/ML services
- `../secrets_manager/` - Secrets Manager
- `../cloudwatch/` - CloudWatch logging and monitoring

## Security Features

- All resources use encryption at rest
- VPC isolation for database and compute resources
- IAM roles with least privilege access
- Security groups with minimal required access
- Secrets stored in AWS Secrets Manager
- Mandatory tagging for compliance and governance

## Monitoring

- CloudWatch logs for all services
- Enhanced monitoring for RDS
- Performance Insights enabled
- Step Functions execution logging
- Custom dashboards and alarms

## Cost Optimization

- Right-sized instances based on environment
- Automated scaling for EKS node groups
- S3 lifecycle policies available
- Reserved capacity options available
- Cost allocation through mandatory tags

## Compliance

- All resources tagged with mandatory organizational tags
- Encryption enabled by default
- Audit logging through CloudTrail (can be added)
- Security best practices implemented

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will permanently delete all resources and data. Ensure you have backups if needed.

## Support

For issues or questions, contact the team specified in the `contact_group` and `contact_name` tags.
