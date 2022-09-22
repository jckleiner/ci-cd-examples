data "aws_kms_secrets" "credentials" {
  secret {
    name    = "db"
    payload = file("${path.module}/db-creds.yml.encrypted")
  }
}

locals {
  db_creds = yamldecode(data.aws_kms_secrets.credentials.plaintext["db"])
}

resource "aws_instance" "my_app_server" {
  ami           = "ami-083e9f3cc36cb84a8" // ubuntu AMI
  instance_type = "t2.micro"

  tags = {
    Name = "username:${local.db_creds.username}---password:${local.db_creds.password}"
  }
}