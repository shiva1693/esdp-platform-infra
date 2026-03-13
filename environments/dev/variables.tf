variable "org" {
  type = string
}

variable "platform" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "region_code" {
  type = string
}

variable "owner" {
  type = string
}

variable "cost_center" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

