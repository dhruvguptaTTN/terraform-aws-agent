
module "ec2-terraform-agent" {
  source              = "git::https://github.com/tothenew/terraform-aws-agent.git"
  key_name            = "dev-terraform-agent"
  security_groups     = ["sg-999999999999"]
  subnet_id           = "subnet-999999999999"
}