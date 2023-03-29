resource "aws_ami" "overviewer" {
  count = var.no_cost ? 0 : 1

  architecture        = "arm64"
  boot_mode           = "uefi"
  ena_support         = true
  root_device_name    = "/dev/sda1"
  virtualization_type = "hvm"
  name                = "stwalkerster/overviewer/*"

  tags = {
    Name      = "overviewer-packer-*"
    Terraform = "Packer"
  }

  lifecycle {
    ignore_changes = [
      tags,
      name
    ]
  }
}

resource "aws_ebs_snapshot" "overviewer" {
  count = var.no_cost ? 0 : 1

  volume_id   = "vol-00000000000000000"
  description = "Overviewer snapshot"

  tags = {
    Name      = "overviewer-packer-*"
    Terraform = "Packer"
  }

  lifecycle {
    ignore_changes = [
      tags,
      description,
      volume_id
    ]
  }
}
