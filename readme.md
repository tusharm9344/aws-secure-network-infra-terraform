AWS VPC Infrastructure with Terraform
-------------------------------------
INTERNET
                        │
                        ▼
               [Internet Gateway]
                        │
          ┌─────────────────────────┐
          │      PUBLIC SUBNET       │
          │      (10.0.1.0/24)      │
          │                         │
          │  [Bastion]   [NAT GW]   │
          └─────────────────────────┘
                │               │
              SSH            outbound
                │               │
          ┌─────────────────────────┐
          │      PRIVATE SUBNET      │
          │      (10.0.2.0/24)      │
          │                         │
          │       [Private EC2]      │
          └─────────────────────────┘
HOW TO DEPLOY ->
# 1. Clone the repo
git clone <your-repo-url>
cd terraform_vpc

# 2. Initialize Terraform
terraform init

# 3. Validate the code
terraform validate

# 4. Preview changes
terraform plan

# 5. Deploy
terraform apply
---------------------------------------------------------
After Deployment
Terraform will output:

vpc_id                 = "vpc-xxxxxxxxx"
public_subnet_id       = "subnet-xxxxxxxxx"
private_subnet_id      = "subnet-xxxxxxxxx"
bastion_public_ip      = "xx.xx.xx.xx"
private_ec2_private_ip = "10.0.2.x"
ssh_command            = "ssh -i firstaws.pem ec2-user@xx.xx.xx.xx"


SSH into Private EC2
# Step 1 - SSH into Bastion
ssh -i firstaws.pem ec2-user@<bastion_public_ip>

# Step 2 - From Bastion, SSH into Private EC2
ssh -i firstaws.pem ec2-user@<private_ec2_private_ip>


Technologies Used

Terraform
AWS VPC
AWS EC2
AWS NAT Gateway
AWS Security Groups
AWS Route Tables
