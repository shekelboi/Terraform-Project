data "aws_key_pair" "tentech_key_pairs" {
  key_pair_id = "key-0cb7efd0f2879fe7c"
}

resource "aws_instance" "ec2" {
  ami                    = "ami-0b0dcb5067f052a63"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.sg_ids
  key_name               = data.aws_key_pair.tentech_key_pairs.key_name
}