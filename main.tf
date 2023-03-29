terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.40"
    }
  }

  backend "s3" {
    bucket = "stwalkerster-terraform-state"
    key    = "state/Sandbox/Overviewer/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "terraform-state-lock"

    assume_role {
      role_arn = "arn:aws:iam::273883981351:role/TerraformState"
    }
  }

  required_version = "~> 1.4.0"
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = local.terraform_role
  }

  default_tags {
    tags = local.tags
  }
}
