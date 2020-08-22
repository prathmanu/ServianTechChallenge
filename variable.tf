variable "location" {
  description = "The location where resources will be created"
  default     = "Australia East"
}
variable "docker_image" {
  description = "The docker image name in acr"
  default     = "techchallengeapp"
}
variable "docker_image_tag" {
  description = "The docker image tag in acr"
  default     = "latest"
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
locals {

  container_registry_name = "techchallengeAcr"
  appservice_name         = "techchallenge-AppService"
  websites_port           = "3000"
}