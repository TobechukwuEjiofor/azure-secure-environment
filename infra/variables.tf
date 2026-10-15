variable "location" {
  type    = string
  default = "uksouth"
}

variable "project" {
  type    = string
  default = "azsecure"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = "tobechukwu"
}

variable "admin_cidr" {
  type        = string
  description = "Your public IP in CIDR form, allowed to SSH to the bastion"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/azsecure_key.pub"
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}
