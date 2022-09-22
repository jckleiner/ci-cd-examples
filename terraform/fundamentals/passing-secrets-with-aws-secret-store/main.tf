# Go to https://eu-central-1.console.aws.amazon.com/secretsmanager
# Make sure its eu-central-1
# create a secret with the name "db-creds"

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "db-creds"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}
resource "aws_instance" "my_app_server" {
  ami           = "ami-083e9f3cc36cb84a8" // ubuntu AMI
  instance_type = "t2.micro"

  tags = {
    Name = "username:${local.db_creds.username}---password:${local.db_creds.password}"
  }
}