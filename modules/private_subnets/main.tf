//============Private subnets==================
resource "aws_subnet" "pc_private_subnet01" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet03_cidr
  availability_zone = "us-east-2a"
  tags = {
    Name = "${var.env_prefix}-pc_private_subnet01"
  }
}
resource "aws_subnet" "pc_private_subnet02" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet04_cidr
  availability_zone = "us-east-2b"
  tags = {
    Name = "${var.env_prefix}-pc_private_subnet02"
  }
}

//============Secure Subnets=======================
resource "aws_subnet" "pc_secure_subnet01" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet05_cidr
  availability_zone = "us-east-2a"
  tags = {
    Name = "${var.env_prefix}-pc_secure_subnet01"
  }
}

resource "aws_subnet" "pc_secure_subnet02" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet06_cidr
  availability_zone = "us-east-2b"
  tags = {
    Name = "${var.env_prefix}-pc_secure_subnet01"
  }
}
//===========Route tables=========================
resource "aws_route_table" "pc_pri_route1" {
  vpc_id = var.vpc_id
  route {
    cidr_block = var.pri_route_cidr
    gateway_id = var.nat_gateway01
  }
  tags = {
    Name = "${var.env_prefix}-pri_route"
  }
}

resource "aws_route_table" "pc_pri_route2" {
  vpc_id = var.vpc_id
  route {
    cidr_block = var.pri_route_cidr
    gateway_id = var.nat_gateway02
  }
  tags = {
    Name = "${var.env_prefix}-pri_route"
  }
}

//============Associations===============================

resource "aws_route_table_association" "pri_route_acsn01" {
  subnet_id      = aws_subnet.pc_private_subnet01.id
  route_table_id = aws_route_table.pc_pri_route1.id
}

resource "aws_route_table_association" "pri_route_acsn02" {
  subnet_id      = aws_subnet.pc_private_subnet02.id
  route_table_id = aws_route_table.pc_pri_route2.id
}

//=============Outputs====================================
output "my_pc_private_subnet_output1" {
  value = aws_subnet.pc_private_subnet01.id
}

output "my_pc_private_subnet_output2" {
  value = aws_subnet.pc_private_subnet02.id
}

output "my_pc_secure_subnet_output1" {
  value = aws_subnet.pc_secure_subnet01.id
}

output "my_pc_secure_subnet_output2" {
  value = aws_subnet.pc_secure_subnet02.id
}



