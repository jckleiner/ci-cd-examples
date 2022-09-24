# terraform {
#   required_providers {
#     aws = {
#       //source  = "hashicorp/aws"
#       //version = "~> 3.27"
#     }
#   }
#   // version of terraform
#   // required_version = "~>0.12.0"
# }

// cloud provider -> AWS
provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

/*
    two strings follow the resource keyword:
        resource "type" "name" {}
    
    This name will be used in terraform only, it's not reflected to AWS or Azure. It's like a variable.
    Terraform will create an object with that name and you can then use that name to lookup things from there.
*/
// aws_instance is an EC2 instance
resource "aws_instance" "my_app_server" {
  #   ami           = "ami-083e9f3cc36cb84a8" // ubuntu AMI
  ami           = var.ami_id // ubuntu AMI
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.allow_port_8080.id ]

  # the resource will be assigned to a default subnet if no ID is given
  # subnet_id = 

  # to be able to SSH into this instance
  # a key pair with this name must be present in your aws account
  # key_name = var.key_pair_name
  
  user_data     = <<-EOF
    #!/bin/bash
    echo "<br><h2>My server is up!</h2>" > index.html
    # nohup busybox httpd -f -p 8080
    python3 -m http.server 8080 &
                 EOF
  tags = {
    Name = "ec2-${var.app_tag_name}"
  }
}

# resource "aws_vpc" "my_vpc" {
#   cidr_block       = "10.0.0.0/16"
#   instance_tenancy = "default"

#   tags = {
#     Name = "my_vpc"
#   }
# }

resource "aws_security_group" "allow_port_8080" {
  name        = "allow_port_8080"
  description = "Allow 8080 inbound traffic"

  // if not defined, it gives the following error:
  // Error: with the retirement of EC2-Classic no new Security Groups can be created without referencing a VPC
  # vpc_id      = var.vpc_id // the default security group
  vpc_id      = data.aws_vpc.default.id

  // for incoming trafic
  ingress {
    // from - to is a range of ports you want to open
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    // allowed IP addresses
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = []
  }

  // for outgoing trafic
  /*
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }*/
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_s3_bucket" "images" {
  # if 'bucket' is not provided, terraform will generate a unique ID
  bucket = "my-demo-s3-bucket-images"
}

resource "aws_s3_bucket" "images_backup" {
  bucket = "my-demo-s3-bucket-images-backup"

  depends_on = [
    aws_s3_bucket.images
  ]
}

