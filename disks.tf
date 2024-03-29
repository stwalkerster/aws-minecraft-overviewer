resource "aws_ebs_volume" "maps" {
  count = var.no_cost ? 0 : 1

  availability_zone = var.availability_zone
  size              = 50

  tags = {
    "Name" = "overviewer-maps"
  }
}

resource "aws_ebs_volume" "worlds" {
  count = var.no_cost ? 0 : 1

  availability_zone = var.availability_zone
  size              = 3

  tags = {
    "Name" = "overviewer-worlds"
  }
}

output "ebs_maps" {
  value = var.no_cost ? null : aws_ebs_volume.maps[0].id
}

output "ebs_worlds" {
  value = var.no_cost ? null : aws_ebs_volume.worlds[0].id
}


resource "aws_instance" "volume_formatter" {
  count = var.format_volume ? 1 : 0

  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t4g.micro"
  iam_instance_profile = "SSMSessionManager"
  subnet_id            = data.aws_subnets.public.ids[0]

  instance_initiated_shutdown_behavior = "terminate"

  tags = {
    Name = "overviewer-volume-formatter"
  }

  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash

    worlds="/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol${trimprefix(aws_ebs_volume.worlds[0].id, "vol-")}"
    maps="/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol${trimprefix(aws_ebs_volume.maps[0].id, "vol-")}"

    while ! test -r $${worlds}; do true; done
    while ! test -r $${maps}; do true; done

    mkfs -text4 -L ${trimprefix(aws_ebs_volume.worlds[0].id, "vol-")} $${worlds}
    mkfs -text4 -L ${trimprefix(aws_ebs_volume.maps[0].id, "vol-")} $${maps}

    shutdown -h now
    EOF

}

resource "aws_volume_attachment" "maps" {
  count = var.format_volume ? 1 : 0

  device_name = "/dev/sdf"
  instance_id = aws_instance.volume_formatter[0].id
  volume_id   = aws_ebs_volume.maps[0].id
}

resource "aws_volume_attachment" "worlds" {
  count = var.format_volume ? 1 : 0

  device_name = "/dev/sdg"
  instance_id = aws_instance.volume_formatter[0].id
  volume_id   = aws_ebs_volume.worlds[0].id
}
