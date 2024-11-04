data "terraform_remote_state" "storage" {
  backend = "s3"

  config = {
    bucket         = var.bucket
    key            = "states/storage.tfstate"
    region         = var.region
    profile        = var.profile
    dynamodb_table = var.dynamodb_table
  }
}

data "terraform_remote_state" "provisioning" {
  backend = "s3"

  config = {
    bucket         = var.bucket
    key            = "states/provisioning.tfstate"
    region         = var.region
    profile        = var.profile
    dynamodb_table = var.dynamodb_table
  }
}
