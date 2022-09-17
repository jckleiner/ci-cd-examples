provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_security_group" "ansible_allow_port_22_and_80" {
  name        = "ansible_allow_port_22_and_80"
  description = "Allow 22 and 80 inbound traffic"

  // if not defined, it gives the following error:
  // Error: with the retirement of EC2-Classic no new Security Groups can be created without referencing a VPC
  vpc_id = data.aws_vpc.default.id // the default security group

  ingress {
    // from - to is a range of ports you want to open
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "nginx" {
  ami                    = "ami-083e9f3cc36cb84a8" // ubuntu AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ansible_allow_port_22_and_80.id]
  # a key pair with this name must be present in your aws account
  key_name = var.key_pair_name

  provisioner "remote-exec" {
    inline = ["echo 'this will be executed on the remote server once the connection (defined below) is ready'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  }
  # once the "remote-exec" block is finished, which means the ssh agent is ready on the remote machine,
  # this block will be executed on the local machine.
  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} nginx.yaml"
  }
}

data "aws_vpc" "default" {
  default = true
}

output "public_ip" {
  value       = aws_instance.nginx.public_ip
  description = "The public IP address of my web server"
}

# required to pass in
variable "key_pair_name" {
    description = "Name of the key pair created in AWS"
    type = string
}

locals {
  private_key_path = "~/Downloads/${var.key_pair_name}.pem"
}