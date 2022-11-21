variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = "No description provided"
}

variable "vpc_id" {
  type = string
}

variable "rules" {
  type = list(list(string))
}

variable "source_is_sg" {
  type    = bool
  default = false
}