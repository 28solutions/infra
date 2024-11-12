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
