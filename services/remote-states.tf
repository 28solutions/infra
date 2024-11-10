data "terraform_remote_state" "storage" {
  backend = "s3"

  config = {
    profile        = var.profile
    region         = var.region
    bucket         = var.bucket
    key            = "states/storage.tfstate"
    dynamodb_table = var.dynamodb_table
  }
}

data "terraform_remote_state" "provisioning" {
  backend = "s3"

  config = {
    profile        = var.profile
    region         = var.region
    bucket         = var.bucket
    key            = "states/provisioning.tfstate"
    dynamodb_table = var.dynamodb_table
  }
}
