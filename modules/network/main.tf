resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.tags, { Name = var.vpc_name_tag })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = var.igw_name_tag })
}

# ------------------------------------------------------------------------------
# SUBNETS
# ------------------------------------------------------------------------------
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az_1
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name                     = "public-1"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = var.az_2
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name                     = "public-2"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "eks_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.eks_az1_cidr
  availability_zone = var.az_1
  tags = merge(var.tags, {
    Name                              = "eks-az1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_subnet" "eks_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.eks_az2_cidr
  availability_zone = var.az_2
  tags = merge(var.tags, {
    Name                              = "eks-az2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_subnet" "eks_az3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.eks_az3_cidr
  availability_zone = var.az_3
  tags = merge(var.tags, {
    Name                              = "eks-az3"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_subnet" "db_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_az1_cidr
  availability_zone = var.az_1
  tags              = merge(var.tags, { Name = "db-isolated-az1" })
}

resource "aws_subnet" "db_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_az2_cidr
  availability_zone = var.az_2
  tags              = merge(var.tags, { Name = "db-isolated-az2" })
}

resource "aws_subnet" "db_az3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_az3_cidr
  availability_zone = var.az_3
  tags              = merge(var.tags, { Name = "db-isolated-az3" })
}

# ------------------------------------------------------------------------------
# NAT GATEWAYS & ROUTING
# ------------------------------------------------------------------------------
resource "aws_eip" "nat_1" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags       = merge(var.tags, { Name = "nat-eip-1" })
}

resource "aws_eip" "nat_2" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags       = merge(var.tags, { Name = "nat-eip-2" })
}

resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id
  tags          = merge(var.tags, { Name = "nat-gateway-1" })
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id
  tags          = merge(var.tags, { Name = "nat-gateway-2" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, { Name = "public-rt" })
}

resource "aws_route_table_association" "pub_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pub_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_nat_1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }
  tags = merge(var.tags, { Name = "private-rt-nat1" })
}

resource "aws_route_table" "private_nat_2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_2.id
  }
  tags = merge(var.tags, { Name = "private-rt-nat2" })
}

resource "aws_route_table_association" "eks_1" {
  subnet_id      = aws_subnet.eks_az1.id
  route_table_id = aws_route_table.private_nat_1.id
}

resource "aws_route_table_association" "eks_2" {
  subnet_id      = aws_subnet.eks_az2.id
  route_table_id = aws_route_table.private_nat_2.id
}

resource "aws_route_table_association" "eks_3" {
  subnet_id      = aws_subnet.eks_az3.id
  route_table_id = aws_route_table.private_nat_1.id
}

resource "aws_route_table" "isolated" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "db-isolated-rt" })
}

resource "aws_route_table_association" "db_1" {
  subnet_id      = aws_subnet.db_az1.id
  route_table_id = aws_route_table.isolated.id
}

resource "aws_route_table_association" "db_2" {
  subnet_id      = aws_subnet.db_az2.id
  route_table_id = aws_route_table.isolated.id
}

resource "aws_route_table_association" "db_3" {
  subnet_id      = aws_subnet.db_az3.id
  route_table_id = aws_route_table.isolated.id
}

# ------------------------------------------------------------------------------
# TIGHTENED NETWORK ACLS
# ------------------------------------------------------------------------------
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  tags       = merge(var.tags, { Name = "public-nacl" })

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
}

resource "aws_network_acl" "eks" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.eks_az1.id, aws_subnet.eks_az2.id, aws_subnet.eks_az3.id]
  tags       = merge(var.tags, { Name = "eks-private-nacl" })

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
}

resource "aws_network_acl" "database" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.db_az1.id, aws_subnet.db_az2.id, aws_subnet.db_az3.id]
  tags       = merge(var.tags, { Name = "db-isolated-nacl" })

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.eks_az1_cidr
    from_port  = 5432
    to_port    = 5432
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.eks_az2_cidr
    from_port  = 5432
    to_port    = 5432
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.eks_az3_cidr
    from_port  = 5432
    to_port    = 5432
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.eks_az1_cidr
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.eks_az2_cidr
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.eks_az3_cidr
    from_port  = 1024
    to_port    = 65535
  }
}

# ------------------------------------------------------------------------------
# EMBEDDED VPC ENDPOINTS
# ------------------------------------------------------------------------------
resource "aws_security_group" "endpoints" {
  name        = "${var.cluster_name}-endpoints-sg"
  description = "Secure boundaries allowing private traffic from nodes into Interface Endpoints"
  vpc_id      = aws_vpc.main.id
  tags        = merge(var.tags, { Name = "vpc-endpoints-sg" })
}

resource "aws_security_group_rule" "endpoints_ingress_https" {
  description              = "HTTPS securely from computational worker nodes"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.endpoints.id
  source_security_group_id = var.eks_cluster_security_group_id
}

resource "aws_security_group_rule" "endpoints_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.endpoints.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.eks_az1.id, aws_subnet.eks_az2.id, aws_subnet.eks_az3.id]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
  tags                = merge(var.tags, { Name = "ecr-dkr-endpoint" })
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.eks_az1.id, aws_subnet.eks_az2.id, aws_subnet.eks_az3.id]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
  tags                = merge(var.tags, { Name = "ecr-api-endpoint" })
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.eks_az1.id, aws_subnet.eks_az2.id, aws_subnet.eks_az3.id]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
  tags                = merge(var.tags, { Name = "logs-endpoint" })
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.eks_az1.id, aws_subnet.eks_az2.id, aws_subnet.eks_az3.id]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
  tags                = merge(var.tags, { Name = "secretsmanager-endpoint" })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_nat_1.id, aws_route_table.private_nat_2.id]
  tags              = merge(var.tags, { Name = "s3-gateway-endpoint" })
}