resource "aws_vpc" "pc_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "${var.env_prefix}-pc_vpc"
  }
}


output "my_pc_vpc_output" {
  value = aws_vpc.pc_vpc.id
}
