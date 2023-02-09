data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  owners = ["amazon"]
}

resource "aws_iam_role" "terraform_agent_role" {
  name               = "${var.project_name_prefix}-terraform-agent-role"
  assume_role_policy = <<POLICY
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Sid" : ""
      }
    ]
  }
  POLICY
  tags               = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-terraform-agent-role" }))

}

resource "aws_iam_instance_profile" "terraform_agent_profile" {
  name = "${var.project_name_prefix}-terraform-agent-instance-profile"
  role = aws_iam_role.terraform_agent_role.name
}

data "aws_iam_policy" "terraform_agent_ssm_mananged_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "_ssm_mananged_instance_core" {
  policy_arn = data.aws_iam_policy.terraform_agent_ssm_mananged_instance_core.arn
  role       = aws_iam_role.terraform_agent_role.id
}



data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
}
resource "aws_instance" "ec2" {
  ami                     = data.aws_ami.amazon-linux-2.id
  instance_type           = var.instance_type
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = var.security_groups
  key_name                = var.key_name
  iam_instance_profile    = aws_iam_instance_profile.terraform_agent_profile.name
  ebs_optimized           = var.ebs_optimized
  disable_api_termination = var.disable_api_termination
  user_data_base64        = base64encode(data.template_file.user_data.rendered)
  source_dest_check       = var.source_dest_check

  volume_tags = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-terraform-agent" }))
  tags        = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-terraform-agent" }))

  root_block_device {
    delete_on_termination = var.delete_on_termination
    encrypted             = var.encrypted
    volume_size           = var.root_volume_size
    volume_type           = var.volume_type
  }
}