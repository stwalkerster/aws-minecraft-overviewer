resource "aws_iam_role" "teamcity_overviewer" {
  name = "TeamCityOverviewer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = ["ec2.amazonaws.com"]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "teamcity_overviewer" {
  role       = aws_iam_role.teamcity_overviewer.name
  policy_arn = aws_iam_policy.teamcity_overviewer.arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.teamcity_overviewer.name
  policy_arn = "arn:aws:iam::${var.target_account}:policy/SessionManagerPermissions"
}

resource "aws_iam_instance_profile" "teamcity_overviewer" {
  name = aws_iam_role_policy_attachment.teamcity_overviewer.role
  role = aws_iam_role_policy_attachment.teamcity_overviewer.role
}

resource "aws_iam_policy" "teamcity_overviewer" {
  name = "TeamCityOverviewer"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["ec2:AttachVolume"]
        Resource = [
          aws_ebs_volume.maps.arn,
          aws_ebs_volume.worlds.arn,
          "arn:aws:ec2:eu-west-1:${var.target_account}:instance/*"
        ]
      },
    ]
  })
}
