variable "platform" {
  type        = string
  description = "Platform for which the Volterra namespace is being configured"
}

variable "key" {
  type        = string
  description = "Key for the Volterra namespace, used to differentiate between multiple namespaces"
}

variable "value" {
  type        = any
  description = "Value for the Volterra namespace, containing specific configuration details"
}