
output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_region" {
  description = "AWS region of the S3 bucket"
  value       = aws_s3_bucket.this.region
}

output "bucket_hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for this bucket's region"
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "bucket_website_endpoint" {
  description = "Website endpoint for the S3 bucket"
  value       = aws_s3_bucket.this.website_endpoint
}

output "bucket_website_domain" {
  description = "Domain of the website endpoint for the S3 bucket"
  value       = aws_s3_bucket.this.website_domain
}

output "versioning_status" {
  description = "Versioning status of the S3 bucket"
  value       = aws_s3_bucket_versioning.this.versioning_configuration[0].status
}

output "encryption_algorithm" {
  description = "Server-side encryption algorithm used"
  value       = var.encryption_algorithm
}

output "public_access_block_enabled" {
  description = "Whether public access block is enabled"
  value       = var.block_public_access
}

output "lifecycle_enabled" {
  description = "Whether lifecycle configuration is enabled"
  value       = var.lifecycle_enabled
}

output "notification_enabled" {
  description = "Whether bucket notifications are enabled"
  value       = var.notification_enabled
}

output "eventbridge_enabled" {
  description = "Whether EventBridge notifications are enabled"
  value       = var.eventbridge_enabled
}
