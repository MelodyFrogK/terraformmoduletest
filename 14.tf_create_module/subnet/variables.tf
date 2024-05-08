# Variable Block
variable "pjt_name" {
  type =  string
  default = ""
}

variable "subnets_block" {
  type = string
  default = "192.168"
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "az_a" {
  type = string
  default = ""
}

variable "az_c" {
  type = string
  default = ""
}