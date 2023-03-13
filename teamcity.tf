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

output "teamcity_access_key_id" {
  value = aws_iam_access_key.teamcity.id
}

output "teamcity_access_key_secret" {
  value     = aws_iam_access_key.teamcity.secret
  sensitive = true
}
