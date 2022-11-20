resource "aws_security_group" "sg" {
  name        = var.name
  description = var.description

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.description
  }
}

resource "aws_security_group_rule" "sg_rule" {
  count             = length(var.rules)
  type              = var.rules[count.index][0]
  from_port         = tonumber(var.rules[count.index][1])
  to_port           = tonumber(var.rules[count.index][2])
  protocol          = var.rules[count.index][3]
  cidr_blocks       = [var.rules[count.index][4]]
  security_group_id = aws_security_group.sg.id
}