variable "image" {
  type        = string
  description = "Name of Docker repository suffixed with version"
}

variable "container" {
  type        = string
  description = "Name of container"
}

variable "internal_port" {
  type        = number
  description = "Container port"
  default     = 8000
}

variable "network" {
  type        = string
  description = "Name of Docker network"
}
