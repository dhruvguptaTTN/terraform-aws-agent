
module "ec2-terraform-agent" {
  source              = "git::https://github.com/tothenew/terraform-aws-agent.git"
  key_name            = "tothenew"
  security_groups     = ["sg-999999999999"]
  subnet_id           = "ssubnet-999999999999"
  project_name_prefix = "dev-tothenew"
  common_tags = {
    "Project"     = "ToTheNew",
    "Environment" = "dev"
  }
}