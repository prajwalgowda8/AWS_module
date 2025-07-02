
output "domain_arn" {
  description = "ARN of the OpenSearch domain"
  value       = aws_opensearch_domain.this.arn
}

output "domain_id" {
  description = "Unique identifier for the OpenSearch domain"
  value       = aws_opensearch_domain.this.domain_id
}

output "domain_name" {
  description = "Name of the OpenSearch domain"
  value       = aws_opensearch_domain.this.domain_name
}

output "endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = aws_opensearch_domain.this.endpoint
}

output "kibana_endpoint" {
  description = "Domain-specific endpoint for Kibana without https scheme"
  value       = aws_opensearch_domain.this.kibana_endpoint
}

output "dashboard_endpoint" {
  description = "Domain-specific endpoint for OpenSearch Dashboards without https scheme"
  value       = aws_opensearch_domain.this.dashboard_endpoint
}

output "security_group_id" {
  description = "Security group ID for the OpenSearch domain"
  value       = aws_security_group.opensearch.id
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.opensearch_logs.name
}
