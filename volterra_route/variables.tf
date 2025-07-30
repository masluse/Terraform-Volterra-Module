variable "ignore_route_changes" {
  type        = bool
  default     = false
  description = "Flag to ignore changes in route configuration."
}

variable "key" {
  type        = string
  description = "A unique key to identify the route configuration."
}

variable "platform" {
  type        = string
  description = "The platform for which the route is being configured."
}

variable "namespace" {
  type        = string
  description = "The namespace in which the route is defined."
}

variable "path_redirects" {
  description = "A map of path redirects for the route."
}