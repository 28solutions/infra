data "terraform_remote_state" "storage" {
  backend = "s3"

  config = {
    access_key     = var.access_key
    secret_key     = var.secret_key
    region         = var.region
    bucket         = var.bucket
    key            = "states/storage.tfstate"
    dynamodb_table = var.dynamodb_table
  }
}

data "terraform_remote_state" "provisioning" {
  backend = "s3"

  config = {
    access_key     = var.access_key
    secret_key     = var.secret_key
    region         = var.region
    bucket         = var.bucket
    key            = "states/provisioning.tfstate"
    dynamodb_table = var.dynamodb_table
  }
}
