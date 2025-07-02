
output "cluster_arn" {
  description = "ARN of the DocumentDB cluster"
  value       = aws_docdb_cluster.this.arn
}

output "cluster_id" {
  description = "DocumentDB cluster identifier"
  value       = aws_docdb_cluster.this.id
}

output "cluster_endpoint" {
  description = "DocumentDB cluster endpoint"
  value       = aws_docdb_cluster.this.endpoint
}

output "cluster_reader_endpoint" {
  description = "DocumentDB cluster reader endpoint"
  value       = aws_docdb_cluster.this.reader_endpoint
}

output "cluster_port" {
  description = "DocumentDB cluster port"
  value       = aws_docdb_cluster.this.port
}

output "cluster_resource_id" {
  description = "DocumentDB cluster resource ID"
  value       = aws_docdb_cluster.this.cluster_resource_id
}

output "cluster_members" {
  description = "List of DocumentDB instances that are part of this cluster"
  value       = aws_docdb_cluster.this.cluster_members
}

output "master_username" {
  description = "DocumentDB master username"
  value       = aws_docdb_cluster.this.master_username
  sensitive   = true
}

output "security_group_id" {
  description = "Security group ID for the DocumentDB cluster"
  value       = aws_security_group.docdb.id
}

output "subnet_group_name" {
  description = "DocumentDB subnet group name"
  value       = aws_docdb_subnet_group.this.name
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DocumentDB credentials"
  value       = aws_secretsmanager_secret.docdb_credentials.arn
}

output "secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret containing DocumentDB credentials"
  value       = aws_secretsmanager_secret.docdb_credentials.name
}

output "instance_arns" {
  description = "ARNs of the DocumentDB cluster instances"
  value       = aws_docdb_cluster_instance.cluster_instances[*].arn
}

output "instance_identifiers" {
  description = "Identifiers of the DocumentDB cluster instances"
  value       = aws_docdb_cluster_instance.cluster_instances[*].identifier
}
