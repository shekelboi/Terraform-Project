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