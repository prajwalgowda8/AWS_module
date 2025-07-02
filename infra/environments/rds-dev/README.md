
# RDS PostgreSQL Development Environment

This environment deploys the sc-rds-postgres-demo RDS PostgreSQL instance using manually created VPC and subnet resources.

## Prerequisites

Before deploying this environment, ensure you have:

1. **Manually Created VPC and Subnets**: Update the VPC and subnet IDs in `main.tf`:
   ```hcl
   vpc_id = "vpc-0123456789abcdef0"  # Replace with your VPC ID
   
   private_subnet_ids = [
     "subnet-0123456789abcdef3",     # Replace with your private subnet IDs
     "subnet-0123456789abcdef4"      # Must be in different AZs for Multi-AZ
   ]
   ```

2. **AWS CLI configured** with appropriate permissions
3. **Terraform installed** (version >= 1.0)

## Database Configuration

- **Instance Name**: sc-rds-postgres-demo
- **Engine**: PostgreSQL 15.4
- **Instance Class**: db.m5.xlarge
- **Storage**: 100 GB initial, up to 1000 GB auto-scaling
- **Multi-AZ**: Enabled for high availability
- **Public Access**: Disabled (private subnets only)
- **Encryption**: Enabled
- **Enhanced Monitoring**: 60-second intervals
- **Performance Insights**: Enabled

## Security Configuration

- **Security Group**: Self-referenced for port 5432 (TCP)
- **Network**: Uses manually created private subnets
- **Credentials**: Stored in AWS Secrets Manager
- **Deletion Protection**: Enabled
- **Final Snapshot**: Enabled (not skipped)

## Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Post-Deployment

After successful deployment:

1. **Retrieve database credentials**:
   ```bash
   aws secretsmanager get-secret-value --secret-id sc-rds-postgres-demo-credentials --region us-east-1
   ```

2. **Connect to the database** (from within the VPC):
   ```bash
   psql -h <db_endpoint> -U postgres -d postgres
   ```

## Mandatory Tags

All resources are tagged with the following mandatory tags:
- `contactGroup`: Database Team
- `contactName`: Jane Smith
- `costBucket`: development
- `dataOwner`: Data Engineering Team
- `displayName`: SC RDS PostgreSQL Demo Development
- `environment`: dev
- `hasPublicIP`: false
- `hasUnisysNetworkConnection`: false
- `serviceLine`: Data Services

## Database Parameters

The following PostgreSQL parameters are configured:
- `shared_preload_libraries`: pg_stat_statements
- `log_statement`: all
- `log_min_duration_statement`: 1000ms

## Cleanup

To destroy the environment:
```bash
terraform destroy
```

**Note**: Due to deletion protection being enabled, you may need to disable it first or use the `--target` flag to destroy specific resources.
