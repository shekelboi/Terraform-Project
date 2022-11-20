variable "vpc_id" {
  type = string
}

variable "route" {
  type = map(any)
}

variable "subnets" {
  type = list(string)
}