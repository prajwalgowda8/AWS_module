
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Import existing VPC
resource "aws_vpc" "imported" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.vpc_name
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Import existing Internet Gateway
resource "aws_internet_gateway" "imported" {
  count = var.internet_gateway_id != null ? 1 : 0
  
  vpc_id = aws_vpc.imported.id

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.internet_gateway_name
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Import existing public subnets
resource "aws_subnet" "public_imported" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.imported.id
  cidr_block              = var.public_subnets[count.index].cidr_block
  availability_zone       = var.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = var.public_subnets[count.index].map_public_ip_on_launch

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    var.public_subnets[count.index].tags,
    {
      Name                        = var.public_subnets[count.index].name
      "kubernetes.io/role/elb"    = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Import existing private subnets
resource "aws_subnet" "private_imported" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.imported.id
  cidr_block        = var.private_subnets[count.index].cidr_block
  availability_zone = var.private_subnets[count.index].availability_zone

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    var.private_subnets[count.index].tags,
    {
      Name                              = var.private_subnets[count.index].name
      "kubernetes.io/role/internal-elb" = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Import existing NAT Gateways
resource "aws_nat_gateway" "imported" {
  count = length(var.nat_gateways)

  allocation_id = var.nat_gateways[count.index].allocation_id
  subnet_id     = aws_subnet.public_imported[var.nat_gateways[count.index].subnet_index].id

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.nat_gateways[count.index].name
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Import existing route tables
resource "aws_route_table" "public_imported" {
  count = length(var.public_route_tables)

  vpc_id = aws_vpc.imported.id

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.public_route_tables[count.index].name
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table" "private_imported" {
  count = length(var.private_route_tables)

  vpc_id = aws_vpc.imported.id

  tags = merge(
    var.mandatory_tags,
    var.additional_tags,
    {
      Name = var.private_route_tables[count.index].name
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Routes for public route tables
resource "aws_route" "public_internet_gateway" {
  count = length(var.public_route_tables)

  route_table_id         = aws_route_table.public_imported[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id != null ? aws_internet_gateway.imported[0].id : null

  lifecycle {
    prevent_destroy = true
  }
}

# Routes for private route tables
resource "aws_route" "private_nat_gateway" {
  count = length(var.private_route_tables)

  route_table_id         = aws_route_table.private_imported[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = length(var.nat_gateways) > count.index ? aws_nat_gateway.imported[count.index].id : null

  lifecycle {
    prevent_destroy = true
  }
}

# Route table associations for public subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public_imported[count.index].id
  route_table_id = aws_route_table.public_imported[var.public_subnets[count.index].route_table_index].id
}

# Route table associations for private subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private_imported[count.index].id
  route_table_id = aws_route_table.private_imported[var.private_subnets[count.index].route_table_index].id
}
