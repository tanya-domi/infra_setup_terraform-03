
resource "aws_subnet" "pc_public_subnet01" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet01_cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env_prefix}-pc_public_subnet01"
  }
}

resource "aws_subnet" "pc_public_subnet02" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet02_cidr
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env_prefix}-pc_public_subnet02"
  }
}
resource "aws_route_table" "pc_pub_route" {
  vpc_id = var.vpc_id
  route {
    cidr_block = var.pub_route_cidr
    gateway_id = var.int_gateway
  }
  tags = {
    Name = "${var.env_prefix}-pc_pub_route1"
  }
}


resource "aws_route_table_association" "pc_pub_route_acsn01" {
  subnet_id      = aws_subnet.pc_public_subnet01.id
  route_table_id = aws_route_table.pc_pub_route.id
}

resource "aws_route_table_association" "pc_pub_route_acsn02" {
  subnet_id      = aws_subnet.pc_public_subnet02.id
  route_table_id = aws_route_table.pc_pub_route.id
}


output "my_pc_public_subnet_output01" {
  value = aws_subnet.pc_public_subnet01.id
}

output "my_pc_public_subnet_output02" {
  value = aws_subnet.pc_public_subnet02.id
}

output "my_pc_pub_route_output" {
  value = aws_route_table.pc_pub_route.id
}


