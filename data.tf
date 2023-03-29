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
    values = ["stwalkerster/overviewer/22.04/${var.minecraft_version}/*"]
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

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.vpc.outputs.vpc_id]
  }

  filter {
    name   = "tag:SubnetType"
    values = ["Public"]
  }

  filter {
    name   = "availability-zone"
    values = [var.availability_zone]
  }
}
