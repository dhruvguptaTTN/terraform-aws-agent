
module "ec2-terraform-agent" {
  source              = "../"
  key_name            = "tothenew"
  security_groups     = ["sg-02e6ebd983b19c810"]
  subnet_id           = "subnet-006ddef68deceb474"
}