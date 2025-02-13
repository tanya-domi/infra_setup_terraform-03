//=======Security group for ec2=========
resource "aws_security_group" "pc_pub_sg" {
  name        = "pc_pub_sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ports_ec2
    iterator = myport
    content {
      description = "TLS from VPC"
      from_port   = myport.value
      to_port     = myport.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-pub_sg"
  }
}

//=======Security group for ALB=========
resource "aws_security_group" "pc_sg_alb" {
  name        = "pc_alb_sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ports_alb
    iterator = myport
    content {
      description = "TLS from VPC"
      from_port   = myport.value
      to_port     = myport.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-alb_sg"
  }
}

//=======Security group for RDS=========
resource "aws_security_group" "sec_rds" {
  name        = "sec_rds"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ports_rds
    iterator = myport
    content {
      description = "TLS from VPC"
      from_port   = myport.value
      to_port     = myport.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-rds"
  }
}

//================ outputs =======================

output "my_pc_ec2_sg_output" {
  value = aws_security_group.pc_pub_sg.id
}

output "my_pc_alb_sg_output" {
  value = aws_security_group.pc_sg_alb.id
}

output "my_pc_rds_sg_output" {
  value = aws_security_group.sec_rds.id
}

output "my_pc_rds_sg_output_name" {
  value = aws_security_group.sec_rds.name
}
