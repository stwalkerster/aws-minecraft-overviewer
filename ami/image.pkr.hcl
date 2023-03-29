variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "version" {
  default = "1.19.4"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  tags = {
    Name      = "overviewer-packer-${var.version}-${local.timestamp}"
    Project   = "MinecraftOverviewer"
    Terraform = "Packer"
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name             = "stwalkerster/overviewer/22.04/${var.version}/${local.timestamp}"
  instance_type        = "t4g.small"
  region               = var.region
  iam_instance_profile = "SSMSessionManager"
  run_tags             = local.tags

  assume_role {
    role_arn     = "arn:aws:iam::265088867231:role/OrganizationAccountAccessRole"
  }

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "arm64"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }

  ssh_username = "ubuntu"

  ami_org_arns = ["arn:aws:organizations::273883981351:organization/o-34twzlewwp"]
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "Dockerfile"
    destination = "/tmp/Dockerfile"
  }

  provisioner "shell" {
    script = "build-image.sh"
    env = {
      mc_version = var.version
    }
  }
}
