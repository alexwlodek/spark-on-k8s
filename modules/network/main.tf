resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "vpc-spark-eks"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "igw-spark-eks" }
  )
}

# Jedno public + jedno private subnet na AZ
locals {
  public_subnet_cidrs = [
    for i in range(length(var.azs)) : cidrsubnet(var.vpc_cidr, 4, i)
  ]

  private_subnet_cidrs = [
    for i in range(length(var.azs)) : cidrsubnet(var.vpc_cidr, 4, i + length(var.azs))
  ]
}

resource "aws_subnet" "public" {
  for_each = { for idx, az in var.azs : idx => {
    az   = az
    cidr = local.public_subnet_cidrs[idx]
  } }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name                     = "public-${each.value.az}"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = { for idx, az in var.azs : idx => {
    az   = az
    cidr = local.private_subnet_cidrs[idx]
  } }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags,
    {
      Name                              = "private-${each.value.az}"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

# Public route table – ruch do Internetu via IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "rtb-public" }
  )
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

# NAT Gateway (jeden dla całej VPC – prosty i tani wariant)
resource "aws_eip" "nat" {
  tags = merge(
    var.tags,
    { Name = "eip-nat" }
  )
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id

  tags = merge(
    var.tags,
    { Name = "nat-gateway" }
  )

  depends_on = [aws_internet_gateway.this]
}

# Private route table – ruch do Internetu przez NAT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "rtb-private" }
  )
}

resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id
}
