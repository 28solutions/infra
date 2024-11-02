variable "bucket" {
  type        = string
  description = "State S3 bucket"
}

variable "region" {
  type        = string
  description = "State AWS region"
}

variable "profile" {
  type        = string
  description = "State AWS profile"
}

variable "dynamodb_table" {
  type        = string
  description = "State DynamoDB table"
}
