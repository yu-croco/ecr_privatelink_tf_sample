// VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

// subnet
resource "aws_subnet" "private_1a_app1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = local.az_a
  tags = {
    Name = "private 1a app 1"
  }
}

resource "aws_subnet" "private_1a_app2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = local.az_a
  tags = {
    Name = "private 1a app 2"
  }
}

resource "aws_subnet" "private_1a_vpc_endpoint" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = local.az_a
  tags = {
    Name = "private 1a vpc endpoint"
  }
}

resource "aws_subnet" "private_1c_app1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = local.az_c
  tags = {
    Name = "private 1c app 1"
  }
}

resource "aws_subnet" "private_1c_app2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
  availability_zone = local.az_c
  tags = {
    Name = "private 1c app 2"
  }
}

resource "aws_subnet" "private_1c_vpc_endpoint" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.6.0/24"
  availability_zone = local.az_c
  tags = {
    Name = "private 1c vpc endpoint"
  }
}

// route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "VPC Endpoint S3"
  }
}

resource "aws_route_table_association" "private" {
  for_each = [
    aws_subnet.private_1a_app1.id,
    aws_subnet.private_1a_app2.id,
    aws_subnet.private_1c_app1.id,
    aws_subnet.private_1c_app2.id,
  ]

  subnet_id      = each.key
  route_table_id = aws_route_table.private.id
}

// security group
resource "aws_security_group" "vpc_endpoint" {
  name   = "vpc_endpoint_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

// VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${local.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private.id]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${local.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  subnet_ids= [aws_subnet.private_1a_vpc_endpoint.id, aws_subnet.private_1c_vpc_endpoint.id]
}

// EC2タイプの場合に必要
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${local.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  // subnet_idsは以下を指定しても動く
  // aws_subnet.private_1a_app1.id, aws_subnet.private_1c_app1.id, aws_subnet.private_1a_app2.id, aws_subnet.private_1c_app2.id
  subnet_ids= [aws_subnet.private_1a_vpc_endpoint.id, aws_subnet.private_1c_vpc_endpoint.id]
}

// Fargateの場合に必要
resource "aws_vpc_endpoint" "logs" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${local.region}.logs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  // subnet_idsは以下を指定しても動く
  // aws_subnet.private_1a_app1.id, aws_subnet.private_1c_app1.id, aws_subnet.private_1a_app2.id, aws_subnet.private_1c_app2.id
  subnet_ids= [aws_subnet.private_1a_vpc_endpoint.id, aws_subnet.private_1c_vpc_endpoint.id]
}

// SSM経由でログインしたい場合に必要
// see: https://aws.amazon.com/jp/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/
resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${local.region}.ssm"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  // subnet_idsは以下を指定しても動く
  // aws_subnet.private_1a_app1.id, aws_subnet.private_1c_app1.id, aws_subnet.private_1a_app2.id, aws_subnet.private_1c_app2.id
  subnet_ids= [aws_subnet.private_1a_vpc_endpoint.id, aws_subnet.private_1c_vpc_endpoint.id]
}
