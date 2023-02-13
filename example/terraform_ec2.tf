
module "terraform_ec2_agent" {
  source              = "git::https://github.com/tothenew/terraform-aws-agent.git"
  vpc_id              = "vpc-999999999999"
  subnet_id           = "subnet-999999999999"
}


