
output "vpc_id" {
  description = "ID of the imported VPC"
  value       = aws_vpc.imported.id
}

output "vpc_arn" {
  description = "ARN of the imported VPC"
  value       = aws_vpc.imported.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the imported VPC"
  value       = aws_vpc.imported.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the imported Internet Gateway"
  value       = length(aws_internet_gateway.imported) > 0 ? aws_internet_gateway.imported[0].id : null
}

output "public_subnet_ids" {
  description = "IDs of the imported public subnets"
  value       = aws_subnet.public_imported[*].id
}

output "private_subnet_ids" {
  description = "IDs of the imported private subnets"
  value       = aws_subnet.private_imported[*].id
}

output "public_subnet_arns" {
  description = "ARNs of the imported public subnets"
  value       = aws_subnet.public_imported[*].arn
}

output "private_subnet_arns" {
  description = "ARNs of the imported private subnets"
  value       = aws_subnet.private_imported[*].arn
}

output "nat_gateway_ids" {
  description = "IDs of the imported NAT Gateways"
  value       = aws_nat_gateway.imported[*].id
}

output "public_route_table_ids" {
  description = "IDs of the imported public route tables"
  value       = aws_route_table.public_imported[*].id
}

output "private_route_table_ids" {
  description = "IDs of the imported private route tables"
  value       = aws_route_table.private_imported[*].id
}
