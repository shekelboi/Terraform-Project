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

module "private_rtb" {
  source  = "./modules/route_table"
  subnets = module.private_subnets[*].id
  vpc_id  = aws_vpc.vpc.id

  route = {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}

module "public_rtb" {
  source  = "./modules/route_table"
  subnets = module.public_subnets[*].id
  vpc_id  = aws_vpc.vpc.id

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

module "public_ec2_security_group" {
  source      = "./modules/security_group"
  name        = "public-ec2-sg"
  description = "Enable SSH and HTTP"
  vpc_id      = aws_vpc.vpc.id
  rules       = [
    ["ingress", "22", "22", "tcp", "0.0.0.0/0"],
    ["ingress", "80", "80", "tcp", "0.0.0.0/0"] # TODO: only enable internally
  ]
}

module "private_ec2_security_group" {
  source       = "./modules/security_group"
  name         = "private-ec2-sg"
  description  = "Enable SSH within the network"
  vpc_id       = aws_vpc.vpc.id
  source_is_sg = true
  rules        = [
    ["ingress", "22", "22", "tcp", module.public_ec2_security_group.id]
  ]
}

module "public_ec2" {
  count     = 2
  source    = "./modules/instance"
  sg_ids    = [module.public_ec2_security_group.id]
  subnet_id = module.public_subnets[count.index % 2].id
}

module "private_ec2" {
  count     = 2
  source    = "./modules/instance"
  sg_ids    = [module.private_ec2_security_group.id]
  subnet_id = module.private_subnets[count.index % 2].id
}

module "target_group" {
  source  = "./modules/target_group"
  name    = "project-tg"
  vpc_id  = aws_vpc.vpc.id
  ec2_ids = module.public_ec2[*].id
}

module "alb_sg" {
  source      = "./modules/security_group"
  name        = "alb-sg"
  description = "Enable HTTPS for everyone and HTTP internally"
  vpc_id      = aws_vpc.vpc.id
  rules       = [
    ["ingress", "443", "443", "tcp", "0.0.0.0/0"],
    ["ingress", "80", "80", "tcp", "0.0.0.0/0"] # Only for redirection
  ]
}

module "alb" {
  source           = "./modules/load_balancer"
  name             = "project-alb"
  sg_id            = module.alb_sg.id
  subnet_ids       = module.public_subnets[*].id
  target_group_arn = module.target_group.arn
}

# TODO: add RDS, RDS subnet group and security group