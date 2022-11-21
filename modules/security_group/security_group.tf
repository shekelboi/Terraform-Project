locals {
  cidr_rules = lookup(var.rules, "cidr", [])
  sg_rules   = lookup(var.rules, "sg", [])
}

resource "aws_security_group" "sg" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

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

resource "aws_security_group_rule" "sg_rule_with_cidr" {
  count             = length(local.cidr_rules)
  type              = local.cidr_rules[count.index][0]
  from_port         = tonumber(local.cidr_rules[count.index][1])
  to_port           = tonumber(local.cidr_rules[count.index][2])
  protocol          = local.cidr_rules[count.index][3]
  cidr_blocks       = [local.cidr_rules[count.index][4]]
  security_group_id = aws_security_group.sg.id
}

# If the source is a security group
resource "aws_security_group_rule" "sg_rule_with_sg" {
  count                    = length(local.sg_rules)
  type                     = local.sg_rules[count.index][0]
  from_port                = tonumber(local.sg_rules[count.index][1])
  to_port                  = tonumber(local.sg_rules[count.index][2])
  protocol                 = local.sg_rules[count.index][3]
  source_security_group_id = local.sg_rules[count.index][4]
  security_group_id        = aws_security_group.sg.id
}