// cloud provider -> AWS
provider "aws" {
  profile = "default"
  region = "eu-central-1"
}

/*
    two strings follow the resource keyword:
        resource "type" "name" {}
    
    This name will be used in terraform only, it's not reflected to AWS or Azure. It's like a variable.
    Terraform will create an object with that name and you can then use that name to lookup things from there.
*/
// aws_instance is an EC2 instance
resource "aws_instance" "my_app_server" {
  ami = "ami-083e9f3cc36cb84a8" // ubuntu AMI
  instance_type = "t2.micro"
  tags = {
    Name = "my_app_server"
  }
}