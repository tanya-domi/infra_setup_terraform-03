resource "aws_internet_gateway" "pc_igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env_prefix}-pc_igw"
  }
}
resource "aws_eip" "pc_nat_gateway01" {
  vpc = true
}

resource "aws_eip" "pc_nat_gateway02" {
  vpc = true
}
resource "aws_nat_gateway" "pc_nat_gw01" {
  allocation_id = aws_eip.pc_nat_gateway01.id
  subnet_id     = var.pub_subnet01
  tags = {
    Name = "${var.env_prefix}-nat_gw-subnet01"
  }
}

resource "aws_nat_gateway" "pc_nat_gw02" {
  allocation_id = aws_eip.pc_nat_gateway02.id
  subnet_id     = var.pub_subnet02
  tags = {
    Name = "${var.env_prefix}-nat_gw-subnet02"
  }
}

// Take above resources into output below
output "my_pc_igw_output" {
  value = aws_internet_gateway.pc_igw.id
}
output "my_pc_nat_gw_output1" {
  value = aws_nat_gateway.pc_nat_gw01.id
}

output "my_pc_nat_gw_output2" {
  value = aws_nat_gateway.pc_nat_gw02.id
}
