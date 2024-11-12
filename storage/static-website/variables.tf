variable "cloud_provider" {
  type        = string
  description = "On which provider should the website be created"

  validation {
    condition     = var.cloud_provider == "aws" || var.cloud_provider == "scw"
    error_message = "Only AWS and Scaleway are supported"
  }
}

variable "bucket" {
  type        = string
  description = "Bucket name"
}

variable "bucket_versioning" {
  type        = bool
  description = "Enable bucket versioning"
  default     = false
}

variable "title" {
  type        = string
  description = "Title of the HTML page"
}

variable "icon" {
  type        = string
  description = "Icon to display on the HTML page"
}

variable "owner" {
  type        = string
  description = "Owner to display"
}
