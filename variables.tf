variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "terraform_role" {
  default = "arn:aws:iam::265088867231:role/Terraform"
  type    = string
}

variable "instance_type" {
  default = "t4g.small"
}

locals {
  tags = merge(var.default_tags, {
    "Terraform"   = "yes"
    "Project"     = "MinecraftOverviewer"
    "Environment" = "Sandbox"
  })
}

variable "availability_zone" {
  default = "eu-west-1b"
}

variable "minecraft_version" {
  default = "1.19.4"
  type    = string
}

variable "format_volume" {
  default = false
  type    = bool
}
