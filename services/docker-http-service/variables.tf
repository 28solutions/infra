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

variable "listening_ip" {
  type        = string
  description = "Publishing interface"
  default     = "127.0.0.1"
}

variable "network" {
  type        = string
  description = "Name of Docker network"
}

variable "host" {
  type        = string
  description = "Traefik rule host"
}

variable "methods" {
  type        = list(string)
  description = "Traefik rule methods"
}

variable "path" {
  type        = string
  description = "Traefik rule path"
  default     = ""
}
