variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "rds_sg_ids" {
  type = list(string)
}