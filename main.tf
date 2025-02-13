terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.1.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "my-pc-bucket3"             # Give the bucket name
    key            = "default/terraform.tfstate" # in the bucket, in default folder, store the state file with terraform.tfstate name
    region         = "us-east-2"                 # in this region
    dynamodb_table = "petclinic-table"           # Now the statefiele in the bucket is locked by this dynamodb table
    encrypt        = "true"
  }
}
resource "aws_s3_bucket" "pc_bucket" {
  bucket = "my-pc-bucket2"
}

provider "aws" {
  region = var.region
}
//================Modules-begin==================================================
module "igw_nat" {
  source       = "./modules/igw_nat"
  env_prefix   = var.env_prefix
  vpc_id       = module.vpc.my_pc_vpc_output
  pub_subnet01 = module.public_subnets.my_pc_public_subnet_output01
  pub_subnet02 = module.public_subnets.my_pc_public_subnet_output02
}

module "private_subnets" {
  source         = "./modules/private_subnets"
  env_prefix     = var.env_prefix
  vpc_cidr_block = var.vpc_cidr_block
  pri_route_cidr = var.pri_route_cidr
  subnet03_cidr  = var.subnet03_cidr
  subnet04_cidr  = var.subnet04_cidr
  subnet05_cidr  = var.subnet05_cidr
  subnet06_cidr  = var.subnet06_cidr
  vpc_id         = module.vpc.my_pc_vpc_output
  nat_gateway01  = module.igw_nat.my_pc_nat_gw_output1
  nat_gateway02  = module.igw_nat.my_pc_nat_gw_output2
}

module "public_subnets" {
  source         = "./modules/public_subnets"
  env_prefix     = var.env_prefix
  vpc_cidr_block = var.vpc_cidr_block
  pub_route_cidr = var.pub_route_cidr
  subnet01_cidr  = var.subnet01_cidr
  subnet02_cidr  = var.subnet02_cidr
  vpc_id         = module.vpc.my_pc_vpc_output
  int_gateway    = module.igw_nat.my_pc_igw_output
}

module "security_group" {
  source     = "./modules/security_group"
  vpc_id     = module.vpc.my_pc_vpc_output
  env_prefix = var.env_prefix
  ports_ec2  = var.ports_ec2
  ports_alb  = var.ports_alb
  ports_rds  = var.ports_rds
}

module "vpc" {
  source         = "./modules/vpc"
  env_prefix     = var.env_prefix
  vpc_cidr_block = var.vpc_cidr_block
}

module "web_server" {
  source        = "./modules/web_server"
  env_prefix    = var.env_prefix
  public_key    = var.public_key
  ami           = var.ami
  instance_type = var.instance_type
  subnet01_app  = module.private_subnets.my_pc_private_subnet_output1
  subnet02_app  = module.private_subnets.my_pc_private_subnet_output2
  //subnet01_app       = module.public_subnets.my_pc_public_subnet_output01
  //subnet02_app       = module.public_subnets.my_pc_public_subnet_output02
  security_group_web = module.security_group.my_pc_ec2_sg_output
  iam_profile        = module.iam_role.instance_profile
  awsrds_endpoint    = module.rds.db_instance_endpoint
  username           = var.username
  password           = var.password
  root_password      = var.root_password
  depends_on         = [module.rds]
}

module "iam_role" {
  source     = "./modules/iam_role"
  env_prefix = var.env_prefix
}



module "rds" {
  source            = "./modules/rds"
  username          = var.username
  password          = var.password
  security_group_id = module.security_group.my_pc_rds_sg_output
  rds_subnet1       = module.private_subnets.my_pc_secure_subnet_output1
  rds_subnet2       = module.private_subnets.my_pc_secure_subnet_output2
  //security_group_name2 = module.security_group.my_pc_rds_sg_output_name
  vpc_id = module.vpc.my_pc_vpc_output

}

# ACM Module - To create and Verify SSL Certificates
module "acm" {
  # source = "terraform-aws-modules/acm/aws"
  # //version = "2.14.0"
  # version = "3.0.0"
  source  = "terraform-aws-modules/acm/aws"
  version = "> 3.0"

  //if its a internal domain, which has dot at the end. we need to remove that like below
  domain_name = trimsuffix(data.aws_route53_zone.my_domain.name, ".")
  zone_id     = data.aws_route53_zone.my_domain.zone_id

  subject_alternative_names = [
    "*.dfordevops.com" // certificate will be valid for any domain which ends with .dfordevops.com
  ]
  tags = {
    Name = "${var.env_prefix}-pc-acm"
  }
}

output "certificate_arn" {
  value = module.acm.acm_certificate_arn
}

// ================================ application load balancer ================
module "alb" {
  # source = "terraform-aws-modules/alb/aws"
  # //version = "5.16.0"
  # version = "6.0.0"
  source  = "terraform-aws-modules/alb/aws"
  version = "> 6.0"

  name               = "${var.env_prefix}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.my_pc_vpc_output
  subnets            = [module.public_subnets.my_pc_public_subnet_output01, module.public_subnets.my_pc_public_subnet_output02]
  security_groups    = [module.security_group.my_pc_alb_sg_output]

  //======Listeners - Redirect from http to https ===========
  // when we enter a webiste it goes to http(80) first and then we can redirect it to https(443) if we have SSL Certificate
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0 # App1 TG associated to this listener
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  // ======Target Groups
  target_groups = [
    # App1 Target Group - TG Index = 0
    {
      name_prefix          = "app1-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      # health_check = {
      #   enabled             = true
      #   interval            = 30
      #   path                = "/login"
      #   port                = "traffic-port"
      #   healthy_threshold   = 3
      #   unhealthy_threshold = 3
      #   timeout             = 6
      #   protocol            = "HTTP"
      #   matcher             = "200-399"
      # }

      //This stickiness is required. because we are using web application, all the sessions requests will stick to 1 ec2 only. 
      stickiness = {
        enabled         = true
        cookie_duration = 86400 // this is 1 day, means if the same user accesses the web application, he will be redirected to same ec2 for 1 day
        type            = "lb_cookie"
      }
      protocol_version = "HTTP1"
      # App1 Target Group - Targets
      targets = {
        my_app1_vm1 = {
          target_id = module.web_server.private_instance01
          port      = 8080
        },
        my_app1_vm2 = {
          target_id = module.web_server.private_instance02
          port      = 8080
        }
      }
      tags = {
        Name = "${var.env_prefix}-pc-targetgroup01"
      } # Target Group Tags
    },

  ]

  //==================== This is where we give the certificate details for HTTPS listene r=======

  https_listeners = [
    # === LISTENER (INDEX = 0)
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
      action_type        = "fixed-response"
      fixed_response = { // when it first comes to http(80) we want this fixed response
        content_type = "text/plain"
        message_body = "Fixed Static message - for Root Context"
        status_code  = "200"
      }
    }
  ]
  //======== HTTPS LISTENERS RULES ===================
  # TARGET LISTENERES
  https_listener_rules = [

    # Rule-1: /app1* should go to App1 EC2 Instances
    {
      https_listener_index = 0
      actions = [
        {
          type               = "forward"
          target_group_index = 0
        }
      ]
      conditions = [{
        path_patterns = ["*"]
      }]
    }
  ]


  tags = {
    Name = "${var.env_prefix}-pc-alb"
  }

}

output "target_group_arns" {
  value = module.alb.target_group_arns
}

output "lb_arn_suffix" {
  value = module.alb.lb_arn_suffix
}

output "target_group_arn_suffixes" {
  value = module.alb.target_group_arn_suffixes
}


// ============================== autoscaling ==================================

resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling"
  custom_suffix    = "asg"

  # Sometimes good sleep is required to have some IAM resources created before they can be used
  # provisioner "local-exec" {
  #   command = "sleep 10"
  # }
}

# Output AWS IAM Service Linked Role
output "service_linked_role_arn" {
  value = aws_iam_service_linked_role.autoscaling.arn
}



// ==================== AUTOSCALING WITH LAUNCH TEMPLATES ==============================================
# Launch Template Resource
resource "aws_launch_template" "my_launch_template" {
  name          = "my-launch-template"
  description   = "My Launch template"
  image_id      = var.ami
  instance_type = var.instance_type2
  iam_instance_profile {
    arn = module.iam_role.instance_profile_arn
  }
  vpc_security_group_ids = [module.security_group.my_pc_ec2_sg_output]
  key_name               = module.web_server.key
  user_data = base64encode(
    templatefile("${path.module}/modules/web_server/templates/instance_init_config.tpl", {
      ENDPOINT       = module.rds.db_instance_endpoint
      MYSQL_USERNAME = var.username
      MYSQL_PASSWORD = var.password
      ROOT_PASSWORD  = var.root_password
    })
  )
  instance_initiated_shutdown_behavior = "terminate"
  ebs_optimized                        = false
  #default_version = 1
  update_default_version = true
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      #volume_size = 10      
      volume_size           = 20 # LT Update Testing - Version 2 of LT              
      delete_on_termination = true
      volume_type           = "gp2" # default  is gp2 
    }
  }
  monitoring {
    enabled = false
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "myasg"
    }
  }

}
# Launch Template Outputs
## launch_template_id
output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.my_launch_template.id
}
## launch_template_latest_version
output "launch_template_latest_version" {
  description = "Launch Template Latest Version"
  value       = aws_launch_template.my_launch_template.latest_version
}

# Autoscaling Outputs
## autoscaling_group_id
output "autoscaling_group_id" {
  description = "Autoscaling Group ID"
  value       = aws_autoscaling_group.my_asg.id
}

## autoscaling_group_name
output "autoscaling_group_name" {
  description = "Autoscaling Group Name"
  value       = aws_autoscaling_group.my_asg.name
}
## autoscaling_group_arn
output "autoscaling_group_arn" {
  description = "Autoscaling Group ARN"
  value       = aws_autoscaling_group.my_asg.arn
}


//==================/========================/====================/======================

# Autoscaling Group Resource
resource "aws_autoscaling_group" "my_asg" {
  name_prefix         = "${var.env_prefix}-my-asg"
  desired_capacity    = 4
  max_size            = 4
  min_size            = 3
  vpc_zone_identifier = [module.private_subnets.my_pc_private_subnet_output1, module.private_subnets.my_pc_private_subnet_output2]
  target_group_arns   = module.alb.target_group_arns
  health_check_type   = "EC2"


  health_check_grace_period = 300 # default is 300 seconds
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = aws_launch_template.my_launch_template.latest_version
  }
  # Instance Refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      # instance_warmup = 300 # Default behavior is to use the Auto Scaling Groups health check grace period value
      min_healthy_percentage = 95
    }
    triggers = ["desired_capacity"] # You can add any argument from ASG here, if those has changes, ASG Instance Refresh will trigger   
  }
  tag {
    key                 = "Owners"
    value               = "Web-Team"
    propagate_at_launch = true
  }
}


//============================/===========================================
###### Target Tracking Scaling Policies ######
# TTS - Scaling Policy-1: Based on CPU Utilization
# Define Autoscaling Policies and Associate them to Autoscaling Group
resource "aws_autoscaling_policy" "avg_cpu_policy_greater_than_xx" {
  name                      = "avg-cpu-policy-greater-than-xx"
  policy_type               = "TargetTrackingScaling" # Important Note: The policy type, either "SimpleScaling", "StepScaling" or "TargetTrackingScaling". If this value isn't provided, AWS will default to "SimpleScaling."    
  autoscaling_group_name    = aws_autoscaling_group.my_asg.id
  estimated_instance_warmup = 180 # defaults to ASG default cooldown 300 seconds if not set
  # CPU Utilization is above 95
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 95
  }

}

// =============================/===============/========================
# Create Scheduled Actions
## Create Scheduled Action-1: Increase capacity during business hours
# resource "aws_autoscaling_schedule" "increase_capacity_7am" {
#   scheduled_action_name  = "increase-capacity-7am"
#   min_size               = 3
#   max_size               = 4
#   desired_capacity       = 3
#   start_time             = "2030-03-30T11:00:00Z" # Time should be provided in UTC Timezone (11am UTC = 7AM EST)
#   recurrence             = "00 09 * * *"
#   autoscaling_group_name = aws_autoscaling_group.my_asg.id
# }
# ### Create Scheduled Action-2: Decrease capacity during business hours
# resource "aws_autoscaling_schedule" "decrease_capacity_5pm" {
#   scheduled_action_name  = "decrease-capacity-5pm"
#   min_size               = 3
#   max_size               = 4
#   desired_capacity       = 3
#   start_time             = "2030-03-30T21:00:00Z" # Time should be provided in UTC Timezone (9PM UTC = 5PM EST)
#   recurrence             = "00 21 * * *"
#   autoscaling_group_name = aws_autoscaling_group.my_asg.id
# }


// ===================================/=======================/=============================
## SNS - Topic
# resource "aws_sns_topic" "myasg_sns_topic" {
#   name = "myasg-sns-topic-${random_pet.this.id}"
# }

# ## SNS - Subscription
# resource "aws_sns_topic_subscription" "myasg_sns_topic_subscription" {
#   topic_arn = aws_sns_topic.myasg_sns_topic.arn
#   protocol  = "email"
#   endpoint  = "dinesh.semac9@gmail.com"
# }

# ## Create Autoscaling Notification Resource
# resource "aws_autoscaling_notification" "myasg_notifications" {
#   group_names = [aws_autoscaling_group.my_asg.id]
#   notifications = [
#     "autoscaling:EC2_INSTANCE_LAUNCH",
#     "autoscaling:EC2_INSTANCE_TERMINATE",
#     "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
#     "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
#   ]
#   topic_arn = aws_sns_topic.myasg_sns_topic.arn
# }

//=====================================================================================





# //========== Route 53 ==========
# # Get the details of my domain ================
data "aws_route53_zone" "my_domain" {
  name         = "dfordevops.com"
  private_zone = false
}

// retrive the zonid of my domain ====================
output "mydomain_zoneid" {
  description = "The Hosted Zone id of the desired Hosted Zone"
  value       = data.aws_route53_zone.my_domain.zone_id
}

output "mydomain_name" {
  description = "The Hosted domain name of the desired Hosted Zone"
  value       = data.aws_route53_zone.my_domain.name
}

# DNS Registration 
# resource "aws_route53_record" "apps_dns" {
#   zone_id = data.aws_route53_zone.my_domain.zone_id
#   name    = "apps1.dfordevops.com"
#   type    = "A"
#   //ttl = "300" This is required only for non-alias, but we are creating it for alias dns names
#   alias {
#     name                   = module.alb.this_lb_dns_name
#     zone_id                = module.alb.this_lb_zone_id
#     evaluate_target_health = true
#   }
# }
