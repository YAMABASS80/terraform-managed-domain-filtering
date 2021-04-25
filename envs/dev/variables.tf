variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "ami_id" {
  type    = string
  default = "ami-06098fd00463352b6"
}

variable "iam_role" {
  type    = string
  default = "AmazonSSMRoleForInstancesQuickSetup"
}
