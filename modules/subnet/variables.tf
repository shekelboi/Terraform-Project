variable "vpc_id" {
  type = string
}

variable "cidr" {
  type = string
}

variable "is_public" {
  type    = bool
  default = false
}