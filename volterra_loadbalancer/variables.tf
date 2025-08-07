variable "value" {
  type        = any
  description = "The value for the Volterra resources."
}

variable "key" {
  type        = string
  description = "The key for the Volterra resources."
}

variable "tenant" {
  type        = string
  description = "The tenant for which the Volterra resources are being configured."
}

variable "platform" {
  type        = string
  description = "Platform for which the Volterra resources are being configured, e.g., GCP, AZURE, MULTI."
}

variable "trusted_clients" {
  description = "The configuration of the trusted clients"
}