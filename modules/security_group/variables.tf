variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = "No description provided"
}

variable "rules" {
  type = list(list(string))
}