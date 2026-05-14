locals {
  pod_subnet_map = length(var.pod_subnet_cidrs) > 0 ? zipmap(var.availability_zones, var.pod_subnet_cidrs) : {}
}

# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

#Public Subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidrs) > 0 ? length(var.public_subnet_cidrs) : 1

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                           = "${var.name_prefix}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb"                       = "1"
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
  })
}

#Private Subnets - Node IPs Only
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidrs) > 0 ? length(var.private_subnet_cidrs) : 1

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name                                           = "${var.name_prefix}-private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb"              = "1"
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
    "karpenter.sh/discovery" = var.cluster_name
  })
}

resource "aws_subnet" "pod_subnet" {
  for_each = local.pod_subnet_map

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-pod-subnet-${substr(each.key, -2, -1)}"
    # VPC CNI discovers pod subnets via this tag
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"

  })
}

# NAT Gateway
resource "aws_eip" "nat" {
  count  = var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "this" {
  count         = var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  # connectivity_type = "public"
  depends_on = [aws_internet_gateway.this]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gateway-${count.index + 1}"
  })
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Tables (one per node subnet for NAT HA)
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-rt-${count.index + 1}"
  })
}

resource "aws_route" "private_default" {
  count = length(var.private_subnet_cidrs)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

#Pod Route Tables (one per pod subnet - for_each matches pod_subnet_map)
resource "aws_route_table" "pod" {
  for_each = local.pod_subnet_map
  vpc_id   = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-pod-rt-${substr(each.key, -2, -1)}"
  })
}

resource "aws_route" "pod_default" {
  for_each = local.pod_subnet_map

  route_table_id         = aws_route_table.pod[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[index(var.availability_zones, each.key)].id
}

resource "aws_route_table_association" "pod" {
  for_each       = local.pod_subnet_map
  subnet_id      = aws_subnet.pod_subnet[each.key].id
  route_table_id = aws_route_table.pod[each.key].id
}