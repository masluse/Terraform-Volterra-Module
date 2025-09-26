variable "platform" {
  type        = string
  description = "The platform for which the Volterra resources are being configured. This is used to differentiate between different environments or deployments."
}

variable "key" {
  type        = string
  description = "A unique identifier for the service policy. This is used to create a distinct name for the service policy resource."
}

variable "value" {
  type = object({
    namespaces    = list(string)
    prefixes      = optional(list(string), [])
    ipv6_prefixes = optional(list(string), [])
  })
  description = "An object containing the configuration values for the service policy, including the namespace and optional lists of IPv4 and IPv6 prefixes."
}