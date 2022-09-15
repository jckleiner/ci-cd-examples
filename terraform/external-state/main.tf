
terraform {
  # configuration to use the s3 bucket as the backend
  backend "s3" {
    bucket = "com-greydev-bucket-to-hold-state-3"
    key = "global/s3/terraform.tfstate"
    region = "eu-central-1"

    dynamodb_table = "terraform-state-locks"
    encrypt = true
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}


resource "aws_s3_bucket" "terraform_app_state" {
  # must be globally unique
  bucket = "com-greydev-bucket-to-hold-state-3"

  # prevents the deletion of this S3 bucket
  # because this holds the state file, even if its empty
  lifecycle {
    # prevent_destroy = true
  }

  # *** DEPRECATED *** Use the aws_s3_bucket_server_side_encryption_configuration resource instead
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # *** DEPRECATED ***, use the aws_s3_bucket_versioning resource instead
#   versioning {
#     enabled = true
#   }

  /*
    Other options:
        - Enable versioning
        - Enable encryption
  */
}

resource "aws_dynamodb_table" "terraform_state_lock" {
    # table name
    name = "terraform-state-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
}
