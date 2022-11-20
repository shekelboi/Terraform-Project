resource "aws_route_table" "rtb" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.route["cidr_block"]
    gateway_id = var.route["gateway_id"]
  }
}

resource "aws_route_table_association" "rtba" {
  count          = length(var.subnets)
  route_table_id = aws_route_table.rtb.id
  subnet_id      = var.subnets[count.index]
}