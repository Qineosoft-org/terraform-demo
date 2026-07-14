
locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}


resource "aws_vpc" "core_banking" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = "true"

  tags = {

    Name        = "${var.environment}-vpc"
    environment = var.environment
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.core_banking.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    name        = "${var.environment}-${element(local.availability_zones, count.index)}-pubic_subnet"
    environment = "${var.environment}"

  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.core_banking.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    name        = "${var.environment}-${element(local.availability_zones, count.index)}-private_subnet"
    environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.core_banking.id
  tags = {

    Name        = "${var.environment}-igw"
    environment = var.environment
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  depends_on = [
    aws_internet_gateway.igw

  ]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  tags = {
    Name        = "nat-gateway-${var.environment}"
    environment = "var.environment"

  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.core_banking.id
  tags = {
    name        = "${var.environment}-private-route-table"
    environment = "${var.environment}"
  }

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.core_banking.id
  tags = {
    name        = "${var.environment}-public-route-table"
    environment = "${var.environment}"

  }
}


resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
