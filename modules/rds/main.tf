provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "my-test-sql" {
  instance_class    = "db.t3.micro"
  engine            = "mysql"
  engine_version    = "8.0"
  multi_az          = true
  storage_type      = "gp2"
  allocated_storage = 20
  //name                    = "mytestrds"
  username                = var.username
  password                = var.password
  apply_immediately       = "true"
  backup_retention_period = 10
  backup_window           = "09:46-10:16"
  db_subnet_group_name    = aws_db_subnet_group.my-rds-db-subnet.name
  vpc_security_group_ids  = [var.security_group_id]
  skip_final_snapshot     = true
}

resource "aws_db_subnet_group" "my-rds-db-subnet" {
  name       = "my-rds-db-subnet"
  subnet_ids = [var.rds_subnet1, var.rds_subnet2]
}


output "db_instance_endpoint" {
  value = aws_db_instance.my-test-sql.endpoint
}
