data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "stwalkerster-terraform-state"
    key    = "state/Sandbox/VPC/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ami" "stw_overviewer" {
  most_recent = true

  filter {
    name   = "name"
    values = ["stwalkerster/overviewer/22.04/1.19/*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

data "dns_a_record_set" "teamcity" {
  host = "spearow.lon.stwalkerster.net"
}
