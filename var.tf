locals {
  az_a = "${var.region}a"
  az_c = "${var.region}c"
}

variable "region" {
  type    = string
  default = "ap-northeast-1"
}
