region = "us-east-2"

vpc_cidr_block = "10.20.0.0/16"
env_prefix     = "pet-clininc"


pub_route_cidr = "0.0.0.0/0"

//pri_subnet_cidr_block = "10.0.20.0/24"
pri_route_cidr = "0.0.0.0/0"

ports_ec2 = [80, 8080]
ports_alb = [22, 80, 443, 8080]
ports_rds = [3306]
//alb_ports     = [22, 80]
instance_type  = "t2.micro"
instance_type2 = "t2.micro"
ami            = "ami-08db74e24d79b5c69" //ubuntu20

//public_key = "/root/.ssh/id_rsa.pub"

//public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDPt2BVHg64+nnZXWESt6pz8jgZG31wyeO8vYf9wulPQsLUxB5qPx6NiX+OVw7vuSzKvYGVCJpdbrtx7n7kx6ufP1BKI9QhYLFTxrF7balXxeo77KIqyySCKZdkIS2NjDnnAlYS6gAYh6YESKipoedM9/7/Hn/QrtBxqdaMpnNYc3EuE+h4xuQl2dPdr1oYcGdjfu2BRfI0JCgvkNdGJQJEBHcMIfMtZjjoajSyKcVS5tibE0BcZfHrOUj2LIpoHKZU5dMPA30kyKpzATx3r1tPSQ3IE76gWWE0m3ibdYnV6ujROXtHIblf7fYXkGKcxCJ3A6SkQQzATvmyUz+qNw7 Robotics@Yeshwi"

//=========== EC2 public key ===========
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvJI8DYlS8XH4dhlxltwOHgU4URtOHKRztr1MB0I++AoZF0YP4dER/TDWuc87y+OYCybuRO29UB1gBNb3P3lCv9Z6E28frjOTBQxUZVHHqTEaYOfI4bPhnnkFdFdmu4JxfRxnyKHncf9YDSD+Ot4Y7gXTqqfazqH7oojaK5UIhiWJt8Zfij1koJDvt0ycFQG6mvqYlP7BwW/dDuxPc3okWEAAPxXuYQP5qe1is3uP64yk986hplxlgIoK3c3lyKLQv1/az6HhNjyUaVT/iW1e5Qw4PGmFR6I0CNQrzbMmA9RE63ZrMzmPySiHydh++7geRp4EnKY8lHHT0yrv7wkr/ root@ip-10-0-10-41.us-east-2.compute.internal"

//public_key = "for-part3-g.pem"

//public
subnet01_cidr = "10.20.1.0/24"
subnet02_cidr = "10.20.2.0/24"


//private
subnet03_cidr = "10.20.3.0/24"
subnet04_cidr = "10.20.4.0/24"

subnet05_cidr = "10.20.5.0/24"
subnet06_cidr = "10.20.6.0/24"


domain_name      = "dfordevops.com"
alternative_name = "*.dfordevops.com"


username = "petclinic"
password = "petclinic"



root_password = "root"
