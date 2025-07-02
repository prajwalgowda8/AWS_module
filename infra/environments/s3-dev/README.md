
# S3 Development Environment

This environment deploys the sc-s3-demo S3 bucket with comprehensive security and lifecycle configurations.

## Prerequisites

Before deploying this environment, ensure you have:

1. **AWS CLI configured** with appropriate permissions
2. **Terraform installed** (version >= 1.0)
3. **S3 bucket permissions** for creating and managing buckets

## Bucket Configuration

- **Bucket Name**: sc-s3-demo-dev-{random-suffix}
- **Type**: General Purpose bucket
- **Versioning**: Enabled
- **Encryption**: AES256 server-side encryption
- **Public Access**: Blocked (secure by default)
- **Lifecycle Management**: Enabled with intelligent tiering
- **Notifications**: EventBridge enabled

## Security Features

- **Public Access Block**: All public access blocked
- **Versioning**: Enabled for data protection
- **Server-Side Encryption**: AES256 encryption by default
- **Lifecycle Rules**: Automatic transition to cost-effective storage classes

## Lifecycle Configuration

The bucket includes two lifecycle rules:

1. **Delete Old Versions**: Removes non-current versions after 90 days
2. **Storage Class Transitions**:
   - Standard to Standard-IA after 30 days
   - Standard-IA to Glacier after 90 days

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

1. **Verify bucket creation**:
   ```bash
   aws s3 ls | grep sc-s3-demo
   ```

2. **Check bucket configuration**:
   ```bash
   aws s3api get-bucket-versioning --bucket <bucket-name>
   aws s3api get-bucket-encryption --bucket <bucket-name>
   ```

3. **Test EventBridge notifications** (if configured):
   ```bash
   aws events list-rules --name-prefix s3-
   ```

## Usage Examples

1. **Upload a file**:
   ```bash
   aws s3 cp local-file.txt s3://<bucket-name>/
   ```

2. **List bucket contents**:
   ```bash
   aws s3 ls s3://<bucket-name>/
   ```

3. **Sync a directory**:
   ```bash
   aws s3 sync ./local-directory s3://<bucket-name>/remote-directory/
   ```

## Mandatory Tags

All resources are tagged with the following mandatory tags:
- `contactGroup`: Storage Team
- `contactName`: Mike Johnson
- `costBucket`: development
- `dataOwner`: Data Platform Team
- `displayName`: SC S3 Demo Development
- `environment`: dev
- `hasPublicIP`: false
- `hasUnisysNetworkConnection`: false
- `serviceLine`: Storage Services

## Monitoring and Alerts

The bucket is configured with:
- EventBridge notifications for object-level events
- CloudTrail integration for API-level logging
- Cost optimization through lifecycle policies

## Cleanup

To destroy the environment:
```bash
terraform destroy
```

**Note**: Ensure the bucket is empty before destroying, or set `force_destroy = true` in the configuration.
