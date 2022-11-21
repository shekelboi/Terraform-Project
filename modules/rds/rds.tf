resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "rds" {
  allocated_storage      = 20
  db_name                = var.name
  engine                 = "mysql"
  engine_version         = "5.7.34"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "adminadmin"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = var.rds_sg_ids
}