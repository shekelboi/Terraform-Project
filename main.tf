resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = {
    Name = "Terraform Project VPC"
  }
}

data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  cidr         = cidrsubnets(aws_vpc.vpc.cidr_block, 2, 2, 2, 2)
  public_cidr  = slice(local.cidr, 0, 2)
  private_cidr = slice(local.cidr, 2, 4)
}

module "private_subnets" {
  source            = "./modules/subnet"
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr              = local.private_cidr[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index % 2]
}

module "public_subnets" {
  source            = "./modules/subnet"
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr              = local.public_cidr[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index % 2]
  is_public         = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  subnet_id     = module.private_subnets[0].id
  allocation_id = aws_eip.eip.id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

module "private_rtb" {
  source = "./modules/route_table"
  route  = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  subnets = module.private_subnets[*].id
  vpc_id  = aws_vpc.vpc.id
}

module "public_rtb" {
  source = "./modules/route_table"
  route  = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  subnets = module.public_subnets[*].id
  vpc_id  = aws_vpc.vpc.id
}

module "security_group" {
  source      = "./modules/security_group"
  name        = "ec2-sg"
  description = "Enable SSH and HTTP"
  rules       = [
    ["ingress", "22", "22", "tcp", "0.0.0.0/0"],
    ["ingress", "80", "80", "tcp", "0.0.0.0/0"]
  ]
}