resource "aws_iam_user" "teamcity" {
  name = "teamcity"
  path = "/terraform/"
}

resource "aws_iam_user_policy_attachment" "teamcity_policies" {
  for_each = {
    "agent-policy" = aws_iam_policy.teamcity_agent_policy.arn,
  }

  user       = aws_iam_user.teamcity.name
  policy_arn = each.value
}

resource "aws_iam_policy" "teamcity_agent_policy" {
  name = "teamcity-agent-policy"

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:RebootInstances",
          "ec2:RunInstances",
          "ec2:ModifyInstanceAttribute",
          "ec2:*Tags",

          # Spot instances
          "ec2:RequestSpotInstances",
          "ec2:CancelSpotInstanceRequests",

          # Spot fleets
          "ec2:RequestSpotFleet",
          "ec2:DescribeSpotFleetRequests",
          "ec2:CancelSpotFleetRequests",

          # Instance IAM roles
          "iam:PassRole",
          "iam:ListInstanceProfiles",

          # Encrypted EBS volumes
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo",
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid      = "TeamcityAgent"
      },
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_access_key" "teamcity" {
  user = aws_iam_user.teamcity.name
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
    cidr_blocks = concat([for ip in data.dns_a_record_set.teamcity.addrs : "${ip}/32"])
    protocol    = "tcp"
    description = "SSH"
  }

  egress {
    from_port   = 443
    to_port     = 443
    cidr_blocks = [for ip in data.dns_a_record_set.teamcity.addrs : "${ip}/32"]
    protocol    = "tcp"
    description = "TeamCity agent communications"
  }
}

output "teamcity_access_key_id" {
  value = aws_iam_access_key.teamcity.id
}

output "teamcity_access_key_secret" {
  value     = aws_iam_access_key.teamcity.secret
  sensitive = true
}
