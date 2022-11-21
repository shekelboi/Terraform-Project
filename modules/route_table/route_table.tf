resource "aws_route_table" "rtb" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = var.route["cidr_block"]
    nat_gateway_id = lookup(var.route, "nat_gateway_id", null)
    gateway_id     = lookup(var.route, "gateway_id", null)
  }
}

resource "aws_route_table_association" "rtba" {
  count          = length(var.subnets)
  route_table_id = aws_route_table.rtb.id
  subnet_id      = var.subnets[count.index]
}