# terraform.tfvars

# VPC ID where the EC2 instance will be launched
vpc_id = "vpc-0cc47f535e7bdfd8b"

# Subnet ID where the EC2 instance will be launched
subnet_id = "subnet-0aca4c58f1efb3a9e"

# Instance Type for EC2 instance
instance_type = "t3a.medium"

# Prefix for resource names
project_name_prefix = "dev"

# IAM Instance Profile to associate with the EC2 instance (Leave empty if not using)
iam_instance_profile = ""

# Disable EC2 API Termination Protection
disable_api_termination = true

# Whether the EC2 instance is EBS optimized
ebs_optimized = true

# Common tags to assign to resources
common_tags = {
  "Created By" = "terraform"
}

# Whether the EBS volume will be deleted when the instance is deleted
delete_on_termination = true

# Whether the EBS volume will be encrypted
encrypted = true

# Volume type for EC2 instance root volume
volume_type = "gp3"

# Size of the root EBS volume in GB
root_volume_size = 50

# Whether to protect the EC2 instance from stopping
disable_api_stop = false

# Source/Destination check for EC2 instance (set to true for NAT or VPN)
source_dest_check = true
