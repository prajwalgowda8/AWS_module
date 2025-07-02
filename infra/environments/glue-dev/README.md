
# AWS Glue Development Environment

This environment deploys the sc-glue-demo AWS Glue infrastructure with comprehensive ETL capabilities.

## Prerequisites

Before deploying this environment, ensure you have:

1. **AWS CLI configured** with appropriate permissions
2. **Terraform installed** (version >= 1.0)
3. **AWS Glue permissions** for creating and managing Glue resources

## Glue Configuration

- **Database Name**: sc-glue-demo
- **Glue Version**: 5.0
- **Worker Type**: G.1X
- **Number of Workers**: 5
- **Job Bookmarks**: Enabled
- **CloudWatch Metrics**: Enabled
- **Continuous Logging**: Enabled

## Infrastructure Components

### S3 Bucket
- **Purpose**: Storage for Glue scripts, data, and temporary files
- **Versioning**: Enabled
- **Encryption**: AES256 server-side encryption
- **Folders**: 
  - `scripts/` - Glue job scripts
  - `data/` - Input/output data
  - `temp/` - Temporary processing files

### Glue Jobs
1. **data_processing**: General data processing job
2. **etl_pipeline**: ETL pipeline job

### Glue Crawlers
1. **s3_data_crawler**: Crawls S3 data folder daily at 2 AM UTC

### IAM Role
- **Service Role**: AWSGlueServiceRole attached
- **S3 Access**: Full access to the Glue S3 bucket
- **CloudWatch Logs**: Access to write logs

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

1. **Upload Glue scripts** to the S3 bucket:
   ```bash
   aws s3 cp data_processing.py s3://<bucket-name>/scripts/
   aws s3 cp etl_pipeline.py s3://<bucket-name>/scripts/
   ```

2. **Upload sample data** (if needed):
   ```bash
   aws s3 cp sample_data.csv s3://<bucket-name>/data/
   ```

3. **Run a Glue job**:
   ```bash
   aws glue start-job-run --job-name sc-glue-demo-data_processing
   ```

4. **Run a crawler**:
   ```bash
   aws glue start-crawler --name sc-glue-demo-s3_data_crawler
   ```

## Glue Notebook

**Note**: Glue notebook will be uploaded manually through the AWS Glue console or via separate deployment processes. This Terraform configuration focuses on the core Glue infrastructure components.

To create a Glue notebook:
1. Go to AWS Glue Console
2. Navigate to "Notebooks" section
3. Create a new notebook using the IAM role created by this module
4. Use the S3 bucket for storing notebook files

## Monitoring and Logging

- **CloudWatch Logs**: `/aws-glue/jobs/sc-glue-demo`
- **Log Retention**: 14 days
- **Metrics**: Enabled for all jobs
- **Job Bookmarks**: Enabled to track processed data

## Sample Job Scripts

Create these Python scripts and upload to the S3 scripts folder:

### data_processing.py
```python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Your data processing logic here

job.commit()
```

## Mandatory Tags

All resources are tagged with the following mandatory tags:
- `contactGroup`: Data Engineering Team
- `contactName`: Sarah Wilson
- `costBucket`: development
- `dataOwner`: Analytics Team
- `displayName`: SC Glue Demo Development
- `environment`: dev
- `hasPublicIP`: false
- `hasUnisysNetworkConnection`: false
- `serviceLine`: Data Processing Services

## Usage Examples

1. **List Glue jobs**:
   ```bash
   aws glue get-jobs --query 'Jobs[?contains(Name, `sc-glue-demo`)].Name'
   ```

2. **Check job run status**:
   ```bash
   aws glue get-job-runs --job-name sc-glue-demo-data_processing
   ```

3. **View crawler status**:
   ```bash
   aws glue get-crawler --name sc-glue-demo-s3_data_crawler
   ```

4. **Query Glue catalog**:
   ```bash
   aws glue get-tables --database-name sc-glue-demo
   ```

## Cleanup

To destroy the environment:
```bash
terraform destroy
```

**Note**: Ensure all Glue job runs are completed and S3 bucket is empty (or set force_destroy = true) before destroying.
