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
  }

  required_version = "~> 1.3.0"
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = var.terraform_role
  }

  default_tags {
    tags = local.tags
  }
}
