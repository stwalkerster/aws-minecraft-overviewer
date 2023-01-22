variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "terraform_role" {
  default = "arn:aws:iam::265088867231:role/OrganizationAccountAccessRole"
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

variable "enable_instance" {
  default = false
  type = bool
  
}