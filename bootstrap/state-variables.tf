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

variable "dynamodb_table" {
  type        = string
  description = "State DynamoDB table"
}
