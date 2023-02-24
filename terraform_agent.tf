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

resource "aws_security_group" "terraform_agent_sg" {
  name        = "${var.project_name_prefix}-terraform-agent-sg"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-terraform-agent-sg" }))
  description = "Terraform Agent security group"

  egress {
    description = "Allow traffic to internet for Package installation"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "terraform_agent_role" {
  count              = var.iam_instance_profile == "" ? 1 : 0
  name               = "${var.project_name_prefix}-terraform-agent-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  tags               = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-terraform-agent-role" }))

}

resource "aws_iam_instance_profile" "terraform_agent_profile" {
  count = var.iam_instance_profile == "" ? 1 : 0
  name  = "${var.project_name_prefix}-terraform-agent-instance-profile"
  role  = aws_iam_role.terraform_agent_role[0].name
  tags  = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-terraform-agent-profile" }))

}

data "aws_iam_policy" "terraform_agent_ssm_mananged_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "_ssm_mananged_instance_core" {
  count      = var.iam_instance_profile == "" ? 1 : 0
  policy_arn = data.aws_iam_policy.terraform_agent_ssm_mananged_instance_core.arn
  role       = aws_iam_role.terraform_agent_role[0].id
}



data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
}


resource "aws_instance" "ec2" {
  ami                     = data.aws_ami.amazon-linux-2.id
  instance_type           = var.instance_type
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [aws_security_group.terraform_agent_sg.id]
  iam_instance_profile    = var.iam_instance_profile == "" ? aws_iam_instance_profile.terraform_agent_profile[0].name : var.iam_instance_profile
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