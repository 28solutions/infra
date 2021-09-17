variable "aws_profile" {
  type        = string
  description = "Profile defined in $HOME/.aws/credentials"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = var.aws_profile
}
