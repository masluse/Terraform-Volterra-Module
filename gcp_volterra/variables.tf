variable "value" {

}

variable "key" {
  type        = string
  description = "The key for the Volterra resources."
}

variable "service_project_id" {
  type        = string
  description = "The GCP project ID where the Volterra resources will be deployed."
}

variable "region" {
  type        = string
  description = "The GCP region where the Volterra resources will be deployed."
}

variable "network_project_id" {
  type        = string
  description = "The GCP project ID for the shared VPC network."
}

variable "sharedvpc_name" {
  type        = string
  description = "The name of the shared VPC network."
}