//==================== IAM Policy =====================
data "aws_iam_policy" "ssm-role" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}


#Create an IAM Role
resource "aws_iam_role" "ec2_role" {
  name = "${var.env_prefix}-EC2-role-for-SSM"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}



resource "aws_iam_policy_attachment" "pc-attach" {
  name       = "${var.env_prefix}-policy-attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = data.aws_iam_policy.ssm-role.arn
  //policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

// We can attach IAM role directly to ec2 instace, thats why we create instance profile and attach this profile to ec2
resource "aws_iam_instance_profile" "pc-profile" {
  name = "${var.env_prefix}-instance-profile"
  role = aws_iam_role.ec2_role.name
}


output "instance_profile" {
  value = aws_iam_instance_profile.pc-profile.name
}

output "instance_profile_arn" {
  value = aws_iam_instance_profile.pc-profile.arn
}
