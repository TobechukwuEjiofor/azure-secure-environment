variable "location" {
  type    = string
  default = "uksouth"
}

variable "project" {
  type    = string
  default = "azsecure"
}

variable "owner" {
  type    = string
  default = "tobechukwu"
}

variable "allowed_ip" {
  type        = string
  description = "Public IP allowed to reach the state storage account"
}
