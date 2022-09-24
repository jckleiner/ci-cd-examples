provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_instance" "my_app_server_1" {
  ami                    = "ami-083e9f3cc36cb84a8" // ubuntu AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_port_22_and_8080.id]

  subnet_id = "subnet-0863c3c3959be6b87" # my-subnet-1
  key_name  = "ansible-example"

  user_data = <<-EOF
    #!/bin/bash
    echo "<br><h2>Server 1</h2>" > index.html
    # nohup busybox httpd -f -p 8080
    python3 -m http.server 8080 &
                 EOF
  tags = {
    Name = "Server 1"
  }
}

resource "aws_instance" "my_app_server_2" {
  ami                    = "ami-083e9f3cc36cb84a8" // ubuntu AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_port_22_and_8080.id]

  subnet_id = "subnet-089abb38179b6ffe4" # my-subnet-2
  key_name  = "ansible-example"

  user_data = <<-EOF
    #!/bin/bash
    echo "<br><h2>Server 2</h2>" > index.html
    # nohup busybox httpd -f -p 8080
    python3 -m http.server 8080 &
                 EOF
  tags = {
    Name = "Server 2"
  }
}

resource "aws_instance" "my_app_server_3" {
  ami                    = "ami-083e9f3cc36cb84a8" // ubuntu AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_port_22_and_8080.id]

  key_name = "ansible-example"


  user_data = <<-EOF
    #!/bin/bash
    echo "<br><h2>Server 3</h2>" > index.html
    # nohup busybox httpd -f -p 8080
    python3 -m http.server 8080 &
                 EOF
  tags = {
    Name = "Server 3"
  }
}


resource "aws_security_group" "allow_port_22_and_8080" {
  name        = "allow_port_22_and_8080"
  description = "Allow 22 and 8080 inbound traffic"

  // if not defined, it gives the following error:
  // Error: with the retirement of EC2-Classic no new Security Groups can be created without referencing a VPC
  vpc_id = data.aws_vpc.default.id // the default security group

  ingress {
    // from - to is a range of ports you want to open
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // allowed IP addresses
    # ipv6_cidr_blocks = []
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // allowed IP addresses
  }

  egress {
    from_port   = 0     // all ports
    to_port     = 0
    protocol    = "-1"  // all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

