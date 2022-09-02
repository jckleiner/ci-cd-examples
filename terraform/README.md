# Terraform

## Agenda
 1. Understanding IaC
 2. Introduction to Terraform
 3. Learning HCL - the Terraform language
 4. Work with AWS using Terraform
 5. Terraform workflow and commands
 6. Enterprise Terraform best practices
 7. Terraform Modules

### What is DevOps?
Before DevOps, there were the operations team and the developer team. The dev team were responsible of developing the code and the ops team were responsible of deploying and making sure that the code was running properly.

The ops team:
 * Take over "finished" code from the dev team
 * Provision servers, buy the servers, mount them on the server racks and setup everything
 * Deploy the application
 * Configure the application and also the environment (for example JVM, load balancer etc.)
 * Support infrastructure. When things went wrong, they were to respond first.

The way we build and deploy things have changed:
 * Cloud providers like AWS, Azure, etc. now provided the hardware as a service.
 * Continuous deployment is a new requirement. You can't just do a big bang deployment once a while, instead the app sometimes needs to be deployed every 30 minutes.
 * Deployment complexity has increased and this complexity can only be reduced when you know the internal workings of the application. So the developer working on the code can deploy the app in a much easier and better way than a ops person. The alternative is that the dev team documenting every single detail when handing the app over to the ops team. 

These points lead to the movement to make this ops process more automated and controled by software, instead of separate teams. Once you move all of those operations to software, now you have the `development of operations`, you can develop code which does those operations.
 * Operations are now code-driven
 * Developers knowladge is needed for operations, so it's better when the developer writes additional code for operations.
 * You'll now have 2 types of code: Dev code vs Ops code.

> **Infrastructure as Code**: it's basically the goal of converting the steps done manually (for example in a Jenkins or AWS GUI) and automating them using different tools. These tools generally take code to describe the wanted state / configuration. This makes it easy to review, test, create different environments and provides also a version history.

Infrastructure as code is usually **declarative**.

Errors are better handled in terraform compared to an imperative style.

### Terraform vs Ansible
Terraform is responsible for provisioning resousrces on the cloud. It is **not responsible** for what is created on those resources. You can provide an image (AMI or Docker Image) which terraform will then configure on the resource, but creating and managing that image or changing things on the resource is not done with terraform. `Ansible` or `Puppet` are used for those task.

### Terraform
> The definiton is (verb): to change the environment of a planet to make it able to support life. For example "terraforming Mars".

Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services.
Terraform codifies cloud APIs into declarative configuration files.
 * Cloud agnostic: meaning you can write your config/code and then with that code provision resources on different cloud providers.
 * Cloud Indepentent: meaning you don't need to work with the cloud. You can also provision your own local machines. It's extensible, so you can write your own plugins.

#### Terraform Workflow

![terraform-workflow](./images/terraform-workflow.png)

1. Write declarative IaC using HCL (HashiCorp Configuration Language)
2. Run Terraform CLI on the IaC code
   * Init
   * Plan
   * Apply

#### State
State describes the resources which are already available(???). Terraform checks the state before it does changes. This makes sure that your code is **idempotent**.

### Authentication

* **Don't put your account ID and secret in any terraform file!**

The best way is to use the CLI's of the cloud providers. Those will setup and store your credentials in the best way possible and terraform will also know where and how to access those credentials depending on which provider its using.

#### AWS
We will use the `awscli` to configure and store our credentials. Once this is done, terraform will know where to find the credentials.

On the AWS page, after you've logged in, `click on your email > Security Credentials > Access keys > Create New Access Key`.

On your command line type `aws configure` and paste the key id and secret that you just generated and provide the other config options.

This will create an `~/.aws` (in your home directory) folder with 2 files inside:

`~/.aws/config`:
```
[default]
region = eu-central-1
output = json
```

`~/.aws/credentials`:
```
[default]
aws_access_key_id = ...
aws_secret_access_key = ...
```

### Creating Our First Terraform File
The convention is to name your file `main.tf`, which will be the entrypoint.
Here is a simple configuration file:

```
// cloud provider -> AWS
provider "aws" {
  profile = "default"
  region = "eu-central-1"
}

/*
    two strings follow the resource keyword:
        resource "type" "name" {
*/
// aws_instance is an EC2 instance
resource "aws_instance" "my_app_server" {
  ami = "ami-083e9f3cc36cb84a8" // ubuntu ami
  instance_type = "t2.micro"
}
```

Now we need to run `terraform init` on the directory where this `main.tf` file is located.

This will create:
 * `.terraform` folder
 * `.terraform.lock.hcl` file

### Plan

The `terraform plan` command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.

 * Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
 * Compares the current configuration to the prior state and noting any differences.
 * Proposes a set of change actions that should, if applied, make the remote objects match the configuration.

The plan command alone will not actually carry out the proposed changes, and so you can use this command to check whether the proposed changes match what you expected before you apply the changes or share your changes with your team for broader review.

### Apply
The `terraform apply` command executes the actions proposed in a Terraform plan.
Before running apply, `terraform plan` will be executed and terraform will ask the user again for a confirmation before carrying out the changes.

If we do a `terraform plan` now, terraform will check again what the state is and if we changed our `main.tf`. In our case, no changes have been made, so the output will be like this: 

```
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and
found no differences, so no changes are needed.
```

### Destroy
`terraform destroy` will destroy the resources which terraform created.

### Plan with Output File
By default the `terraform plan` command just outputs the plan and does not remember or save it anywhere.
You can use the `-out=...` flag to output the plan into a file.
The best practice is to use the `.tfplan`
 * `terraform plan -out=myplan.tfplan`

Now you can use that exact plan to make your changes `terraform apply ./myplan.tfplan` 

### Resource names

```
resource "type" "name" {
    ...
}
```

This name will be used in terraform only, it's not reflected to AWS or Azure. It's like a variable used by terraform.
Terraform will create an object with that name and you can then use that name to lookup things from there.

If you want to change the name of your resources, you can use the `tags` block to do so.

```
resource "aws_instance" "my_app_server" {
  ami = "ami-083e9f3cc36cb84a8" // ubuntu ami
  instance_type = "t2.micro"
  tags = {
    Name = "my_app_server"
  }
}
```

Now when we do a `terraform apply`, it will do an **update in-place** and will only change the name of the EC2 instance from `-` to `my_app_server`

### Destructive Changes 
Not all changes are modifications. If you want to change the tag of a currently running resource, it can be done **in-place** without destroying the resource.
But some changes cannot be made in-place. For example if you want to change the AMI, a `terraform plan` will show you `Plan: 1 to add, 0 to change, 1 to destroy`. Meaning it first has to destroy and then add the resource again.


### Overview

![terraform-overview](./images/terraform-overview.jpg)

You can think of the AWS provider as a plugin which knows how to interpret and work with the aws provider block. Terraform, using this provider reads the `main.tf` and the credentials and then will call the right AWS API which then will create the wanted resources.

### Folder Structure

 * `.terraform`
 * `terraform.tfstate`
 * `terraform.tfstate.backup`
 * `.terraform.lock.hcl`

#### .terraform
When we did a `terraform init`, it scanned our `main.tf` and identified the providers you need. By default, the bare bones terraform does not have the ability to work with AWS or Azure. When it sees that we want to work with AWS, it will download the AWS provider and save it in the `.terraform` folder. It is an executable file which will do the communication to AWS. Terraform will invoke this executable.

#### terraform.tfstate
This file contains the **state of your infrastructure**.

 * This file can also contain sensitive information

Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.

This state is stored **by default in a local file** named `terraform.tfstate`, but it can also be stored remotely, which works better in a team environment.

Terraform uses this local state to create plans and make changes to your infrastructure.
 * Prior to any operation (apply, plan, etc.), Terraform does a `refresh` to update the state (stored in the local file if not specified otherwise) with the real infrastructure.

In laymens terms, Terraform stores the state of your infrastructure locally in `terraform.tfstate`, before you do an operation, it first does a `refresh`, meaning it will fetch information about the remote resources and will compare it to the locally stored state to find out if anything changed on remote. If yes, it will show you the changes.
For example, if you have a running EC2 instance and you change the tag manually on the GUI and then do a `terraform apply` or `plan`, terraform will display that you are about to change the tag. For terraform the only important state is what you defined in `main.tf`. If you do an apply, it will again remove all the manual changes and will make sure that the EC2 instance is exactly equal to the state in the `main.tf` (or also `terraform.tfstate`)

##### Refresh
The `terraform refresh` command reads the current settings from all managed remote objects and updates the Terraform state to match.

> **Warning**: This command is deprecated, because its default behavior is unsafe if you have misconfigured credentials for any of your providers. See below for more information and recommended alternatives.

This won't modify your real remote objects, but it will modify the Terraform state.

You shouldn't typically need to use this command, because Terraform automatically performs the same refreshing actions as a part of creating a plan in both the `terraform plan` and `terraform apply` commands. This command is here primarily for backward compatibility, but **we don't recommend using it** because it provides no opportunity to review the effects of the operation before updating the state.

##### Sensitive Data in State

Terraform state **can contain sensitive data**, depending on the resources in use and your definition of "sensitive." The state contains resource IDs and all resource attributes. For resources such as databases, this may contain initial passwords.

When using local state, state is stored in plain-text JSON files.

When using remote state, state is only ever held in memory when used by Terraform. It may be encrypted at rest, but this depends on the specific remote state backend.





#### terraform.tfstate.backup
Serves as a backup. Each time `terraform.tfstate` is updated, the old file will be moved to `terraform.tfstate.backup`. So it's like having a commit history of of 2 commits.

#### .terraform.lock.hcl

### TODO
 * AWS don't use the root user to do everything, create a restricted user.
 * What should we check into source control?
 * Tfstate can contain sensitive information?