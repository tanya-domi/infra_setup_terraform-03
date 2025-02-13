
resource "aws_key_pair" "petclinic_key" {
  key_name   = "petclinic-key"
  public_key = var.public_key
}


resource "aws_instance" "pc_server1" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet01_app
  key_name      = aws_key_pair.petclinic_key.key_name
  //user_data     = [data.template_file.web-userdata]
  user_data = templatefile("${path.module}/templates/instance_init_config.tpl", {
    ENDPOINT       = var.awsrds_endpoint
    MYSQL_USERNAME = var.username
    MYSQL_PASSWORD = var.password
    ROOT_PASSWORD  = var.root_password
  })
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.security_group_web]
  iam_instance_profile        = var.iam_profile
  tags = {
    Name = "${var.env_prefix}-pc-app1"
  }
}

resource "aws_instance" "pc_server2" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet02_app
  key_name      = aws_key_pair.petclinic_key.key_name
  user_data = templatefile("${path.module}/templates/instance_init_config.tpl", {
    ENDPOINT       = var.awsrds_endpoint
    MYSQL_USERNAME = var.username
    MYSQL_PASSWORD = var.password
    ROOT_PASSWORD  = var.root_password
  })
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.security_group_web]
  iam_instance_profile        = var.iam_profile
  tags = {
    Name = "${var.env_prefix}-pc-app1"
  }
}

output "private_instance01" {
  value = aws_instance.pc_server1.id
}

output "private_instance02" {
  value = aws_instance.pc_server2.id
}

output "key" {
  value = aws_key_pair.petclinic_key.key_name
}



