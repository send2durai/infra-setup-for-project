# Provider Block
provider "aws" {
  region = var.region
}

## Creating a VPC
resource "aws_vpc" "project-1" {
  cidr_block = var.cidr
  tags = {
    Name    = var.name
    Project = var.project
    Tower   = var.tower
    Owner   = var.owner
    Mail    = var.mail
    Billing = var.billing
  }
}

## Creating Public Subnet under project-1 vpc
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.project-1.id
  cidr_block = var.pub_cidr
  tags = {
    Name    = var.pub_name
    project = var.project
    Tower   = var.tower
    Owner   = var.owner
    Mail    = var.mail
    Billing = var.billing
  }
}

## Creating Private Subnet under project-1 vpc
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.project-1.id
  cidr_block = var.priv_cidr
  tags = {
    Name    = var.priv_name
    Project = var.project
    Tower   = var.tower
    Owner   = var.owner
    Mail    = var.mail
    Billing = var.billing
  }
}

# Creating Internet Gateway and associate with project-1 vpc
resource "aws_internet_gateway" "project1igw" {
  vpc_id = aws_vpc.project-1.id
  tags = {
    Name    = var.igw
    Project = var.project
    Tower   = var.tower
    Owner   = var.owner
    Mail    = var.mail
    Billing = var.billing
  }
}

# Elastic IP for NAT Gateway to connect. NAT G/w used to help the instances that is associated with private subnet to connect internet. 
# Hence, There is a PUBLIC IP required to configure NAT G/W.
resource "aws_eip" "nat-ip" {
  vpc        = true
  depends_on = [aws_internet_gateway.project1igw]
  tags = {
    Name    = var.pri-nat-ip
    Project = var.project
    Tower   = var.tower
    Owner   = var.owner
    Mail    = var.mail
    Billing = var.billing
  }
}

# NAT Gateway for Project-1 VPC
resource "aws_nat_gateway" "project1nat" {
  allocation_id = aws_eip.nat-ip.id
  subnet_id     = aws_subnet.private.id
  tags = {
    Name    = var.nat
    Project = var.project
    Tower   = var.tower
    Owner   = var.owner
    Mail    = var.mail
    Billing = var.billing
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.project-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project1igw.id
  }

  tags = {
    Name    = var.rt
    Project = var.project
    Tower   = var.tower
    Owner   = var.owner
    Mail    = var.mail
    Billing = var.billing
  }
}

# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.project-1.id
  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_nat_gateway.project1nat.id
  }

  tags = {
    Name    = var.privrt
    Project = var.project
    Tower   = var.tower
    Owner   = var.owner
    Mail    = var.mail
    Billing = var.billing
  }
}

# Association between Public Subnet and Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Association between Private Subnet and Private Route Table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
