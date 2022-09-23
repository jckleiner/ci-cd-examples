provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

# TODO external state

locals {
  env = "dev"
}

module "s3" {
  source = "../../modules/s3-bucket"
  force_destroy = true
  bucket_name = "${local.env}-such-bucket-much-wow"
  enable_versioning = false
  enable_server_side_encryption = false
}

# TODO use the outputs of modules here somehow, as an example

# TODO how to split up modules so you can deploy new versions of your app without downtime? - https://livebook.manning.com/book/terraform-in-action/chapter-9/30
/*
 1. Use ansible as a provisioner to setup each instance with the app included
    - Is probably slow since for each deployment of your application, the server needs to be provisioned from the ground up
    - Semi-Immutable infrastructure, meaning there is a chance that not every EC2 instance will be the exact same. 
 2. Use ansible separate from Terraform to provision the server once and then deploy the applicaion multiple times.
    - Mutable infrastructure
 3. Use packer to create AMI's with the application included and then use those to spin up new EC2 instances
    - Immutable infrastructure, every EC2 instance using that AMI will be the exact same
 4. Use packer to create AMI's just to provision the server and then use Ansible to deploy the application
 5. Docker Image with the application built in, deploy to AWS Elastic Container Service (ECS)
    - Docker Layers are cached, so if only our application changes, docker build won't take too long
    - https://www.youtube.com/watch?v=zs3tyVgiBQQ
*/

/*
VPC - DEV
  1 Load balancer
  2 gateway
  2 video-service
  2 suggestion-service

VPC - PROD
  1 Load balancer
  2 gateway
  2 video-service
  2 suggestion-service
*/