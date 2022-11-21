variable "subnet_id" {
  type = string
}

variable "sg_ids" {
  type = list(string)
}

variable "user_data" {
  default = null
}