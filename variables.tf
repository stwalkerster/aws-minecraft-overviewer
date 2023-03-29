variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "instance_type" {
  default = "t4g.small"
}

locals {
  tags = merge(var.default_tags, {
    "Terraform" = "yes"
    "Project"   = "MinecraftOverviewer"
  })

  terraform_role = "arn:aws:iam::${var.target_account}:role/Terraform"
}

variable "target_account" {
  default = "265088867231"
  type    = string
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

variable "no_cost" {
  default     = false
  type        = bool
  description = "Attempts to reduce cost to zero. DANGER: this may destroy data"
}
