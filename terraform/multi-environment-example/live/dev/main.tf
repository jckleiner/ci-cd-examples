provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "s3" {
  source = "../../modules/s3-bucket"
  force_destroy = true
  bucket_name = "DEV-such-bucket-much-wow"
  enable_versioning = true
  # enable_server_side_encryption = true
}

# TODO use the outputs of modules here somehow, as an example