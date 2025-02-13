# Infrastructure provisioning using Terraform

• Best practices are a MUST.

• State must be in Cloud using S3 or Azure Blob Storage.

• For State file security enable S3 cross region replication,
versioning and encryption

• Apply state locking using DynamoDB

• The CICD Pipeline to have three steps and checks:

• On commit to any Branch perform terraform init, validate,
fmt and plan operations, checkov scan is optional

• On pull request creation — perform terraform init, validate
fmt and plan so that reviewer can see what is the change this
pipeline will perform

• On merge the feature is merged to main and
terraform apply happens using GitOps approach.


![Image](https://github.com/user-attachments/assets/47e92027-2016-43fb-9999-1057ef57065a)

# Key requirements for Infrastructure

1. # 3 Subnets Architecture
Public, Private and Secure Subnets.
Public Subnets should have routes to Internet Gateway. 
Private Subnets should have route to NAT
Gateway. 
Secure subnets should not have route to IGW or NAT GW.

2. # Load balancer in Public Subnet
Create Load Balancer in Public Subnet across 2 AZs. 
Create corresponding Listener and Target Groups.

3. # Create Auto Scaling Group
Create the ASG across 2 AZs in private subnet. Attach the ASG to ALB. Desired=1, Min=1, Max=1
The instances should not have public IPs.
Instances should be connecting using SSM or EC2 Instance Connect Endpoint.
Security group should not open port 22.
EC2 should be using a user data script at startup and install the application [Docker Image or
WAR JAR File]. This should be in sync with the ALB Target groups.

4. # Create a RDS cluster.
Create the RDS cluster secure subnet in 2 AZs but can start with 1 AZ to cut cost.

5. # Logs [Stretch Goal]
Application and or docker Logs to be collected in Cloud Watch Logs.

6. # Document RTO and RPO for this application

   
