resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = merge(local.tags, { Name = "${local.project_name}-vpc" })
}

resource "aws_subnet" "main" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(local.tags, { Name = "${local.project_name}-subnet-${count.index}" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${local.project_name}-igw" })
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(local.tags, { Name = "${local.project_name}-route-table" })
}

resource "aws_route_table_association" "main" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
} 

resource "aws_security_group" "cluster" {
  vpc_id = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = "${local.project_name}-cluster-sg" })
}

resource "aws_security_group" "nodes" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = "${local.project_name}-node-sg" })
}
