variable "location" {
  description = "The location where resources will be created"
  default     = "Australia East"
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)

  default = {
    environment = "techchallenge"
  }
}
variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "servian_techchallenge_rg"
}