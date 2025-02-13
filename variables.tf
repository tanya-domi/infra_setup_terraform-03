variable "region" {}


variable "vpc_cidr_block" {}
variable "env_prefix" {}

//variable "pub_subnet_cidr_block" {}
variable "pub_route_cidr" {}

//variable "pri_subnet_cidr_block" {}
variable "pri_route_cidr" {}


variable "instance_type" {}
variable "instance_type2" {}

variable "ami" {}

variable "ports_ec2" {
  type = list(number)
}

variable "ports_alb" {
  type = list(number)
}

variable "ports_rds" {
  type = list(number)
}


variable "public_key" {}




variable "subnet01_cidr" {}
variable "subnet02_cidr" {}

variable "subnet03_cidr" {}
variable "subnet04_cidr" {}


variable "subnet05_cidr" {}
variable "subnet06_cidr" {}


variable "domain_name" {}
variable "alternative_name" {}


//variable "awsrds_endpoint" {}
variable "username" {}
variable "password" {}
variable "root_password" {}
