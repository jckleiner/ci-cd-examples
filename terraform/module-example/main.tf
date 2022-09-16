resource "aws_instance" "my_second_app_server" {
  ami           = "ami-083e9f3cc36cb84a8" // ubuntu AMI
  instance_type = "t2.micro"
}

module "my-s3-module" {
    source = "./s3-module"
    bucket_id = "my-demo-s3-bucket-module-images"
}