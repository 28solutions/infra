variable "access_key" {
  type        = string
  description = "State AWS access key ID"
  sensitive   = true
}

variable "secret_key" {
  type        = string
  description = "State AWS secret access key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "State AWS region"
}

variable "bucket" {
  type        = string
  description = "State S3 bucket"
}

variable "use_lockfile" {
  type        = bool
  description = "State lockfile"
}
