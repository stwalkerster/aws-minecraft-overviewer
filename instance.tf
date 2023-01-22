resource "aws_spot_instance_request" "runner" {
  count = var.enable_instance ? 1 : 0

  ami           = data.aws_ami.stw_overviewer.id
  instance_type = var.instance_type

  spot_price           = 0.06
  wait_for_fulfillment = true

  iam_instance_profile = aws_iam_role.teamcity_overviewer.name
  key_name             = "simon@stwalkerster.co.uk (Jan 2023)"

  vpc_security_group_ids      = [aws_security_group.runner.id]
  associate_public_ip_address = true
  subnet_id                   = data.terraform_remote_state.vpc.outputs.vpc_public_subnet_ids[1]

  root_block_device {
    volume_type = "gp3"
    iops        = 3000
    volume_size = 12
  }

  tags = {
    "Name" = "minecraft-overviewer"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ec2_tag" "runner" { 
  for_each = var.enable_instance ? merge(local.tags, {
    Name = "minecraft-overviewer"
  }) : {}

  resource_id = aws_spot_instance_request.runner[0].spot_instance_id

  key   = each.key
  value = each.value

}

resource "aws_security_group" "runner" {
  name        = "MCOverviewer-runner"
  description = "Minecraft Overviewer runner"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  dynamic "egress" {
    for_each = {
      "SSM comms HTTPS" = 443
      "Apt-get HTTP"    = 80
      "Git SSH"         = 22
    }

    content {
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      to_port          = egress.value
      from_port        = egress.value
      protocol         = "tcp"
      description      = egress.key
    }
  }
}

resource "aws_security_group" "teamcity_agent" {
  name        = "teamcity-agent"
  description = "TeamCity agent"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    cidr_blocks = concat([for ip in data.dns_a_record_set.teamcity.addrs : "${ip}/32"], ["94.174.232.133/32"])
    protocol    = "tcp"
  }

  egress {
    from_port   = 443
    to_port     = 443
    cidr_blocks = [for ip in data.dns_a_record_set.teamcity.addrs : "${ip}/32"]
    protocol    = "tcp"
  }
}

