# Variable Block
variable "pjt_name" {
  type =  string
  default = "mfk"
}

# Variable Block
variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "subnets_block" {
  type = string
  default = "10.0"
}