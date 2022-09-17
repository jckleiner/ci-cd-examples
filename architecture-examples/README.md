# Architecture Examples

## Chosing between Terraform and Ansible/Puppet/Chef/Packer
Here are the main trade-offs to consider:

 1. Configuration Management vs Provisioning
 2. Mutable Infrastructure vs Immutable Infrastructure
 3. Procedural vs Declarative
 4. Master vs Masterless / Agent vs Agentless
 5. Using Multiple Tools Together

### 1. Configuration Management vs Provisioning
Chef, Puppet, Ansible, and SaltStack are all `configuration management tools`, which means they are designed to install and manage software on existing servers. CloudFormation and Terraform are `provisioning tools`, which means they are designed to provision the servers themselves (as well as the rest of your infrastructure, like load balancers, databases, networking configuration, etc)

### 2. Mutable Infrastructure vs Immutable Infrastructure
Configuration management tools such as Chef, Puppet, Ansible, and SaltStack typically default to a **mutable infrastructure** paradigm. For example, if you tell Chef to install a new version of OpenSSL, it’ll run the software update on your existing servers and the changes will happen in-place. Over time, as you apply more and more updates, each server builds up a unique history of changes. This often leads to a phenomenon known as **configuration drift**, where each server becomes slightly different than all the others, leading to subtle configuration bugs that are difficult to diagnose and nearly impossible to reproduce.

If you’re using a provisioning tool such as Terraform to deploy machine images created by Docker or Packer, then every “change” is actually a deployment of a new server (just like every “change” to a variable in functional programming actually returns a new variable). For example, to deploy a new version of OpenSSL, you would create a new image using Packer or Docker with the new version of OpenSSL already installed, deploy that image across a set of totally new servers, and then undeploy the old servers. This approach reduces the likelihood of configuration drift bugs, makes it easier to know exactly what software is running on a server, and allows you to trivially deploy any previous version of the software at any time.

### 3. Procedural vs Declarative
Chef and Ansible encourage a **procedural style** where you write code that specifies, step-by-step, how to to achieve some desired end state. Terraform, CloudFormation, SaltStack, and Puppet all encourage a more **declarative style** where you write code that specifies your desired end state, and the IAC tool itself is responsible for figuring out how to achieve that state.

For example, let’s say you wanted to deploy 10 servers (“EC2 Instances” in AWS lingo) to run v1 of an app. Your terraform code and ansible code will look really similar. But once you want to add 5 more servers, you can't just write `count = 15` in your Ansible code and run it because it will deploy 15 new servers. In Terraform you can do that since terraform checks the current state and acts accordingly.

Problems with procedural IaC tools:
  1. When dealing with procedural code, the state of the infrastructure is not fully captured in the code. Reading through your Ansible templates is not enough to know what’s deployed. You’d also have to know the order in which those templates were applied. Had we applied them in a different order, we might end up with different infrastructure, and that’s not something you can see in the code base itself. In other words, to reason about an Ansible or Chef codebase, you have to know the full history of every change that has ever happened.
    
  2. The reusability of procedural code is inherently limited because you have to manually take into account the current state of the codebase. Since that state is constantly changing, code you used a week ago may no longer be usable because it was designed to modify a state of your infrastructure that no longer exists. As a result, procedural code bases tend to grow large and complicated over time.

The downsides to declarative languages are that your expressive power is limited. You won't have too many logical operators and won't be able to have a fine grained control over how things are done.

### 4. Master Versus Masterless / Agent Versus Agentless
By default, Chef, Puppet, and SaltStack all require that you run a **master server** for storing the state of your infrastructure and distributing updates and also they all require you to install **agent software** (e.g., Chef Client, Puppet Agent, Salt Minion) on each server you want to configure. Every time you want to update something in your infrastructure, you use a client (e.g., a command-line tool) to issue new commands to the master server, and the master server either pushes the updates out to all the other servers, or those servers pull the latest updates down from the master server on a regular basis.

However, having to run a master server has some serious drawbacks:
 * Bootsrapping: You need to first install the agents on the machines you want to provision
 * Extra infrastructure (master server)
 * Maintenance
 * Security

Ansible, CloudFormation, Heat, and Terraform are all masterless by default and do not require you to install an agent.

### 5. Using Multiple Tools Together
You will likely need to use multiple tools to build your infrastructure. Each of the tools you’ve seen has strengths and weaknesses, so it’s your job to pick the right tool for the right job.

Here are three common combinations I’ve seen work well at a number of companies:

 1. Provisioning plus configuration management
 2. Provisioning plus server templating
 3. Provisioning plus server templating plus orchestration

#### 1. Provisioning plus configuration management

Example: Terraform and Ansible. You use Terraform to deploy all the underlying infrastructure, including the network topology (i.e., VPCs, subnets, route tables), data stores (e.g., MySQL, Redis), load balancers, and servers. You then use Ansible to deploy your apps on top of those servers.

This is an easy approach to start with, as there is no extra infrastructure to run (Terraform and Ansible are both client-only applications) and there are many ways to get Ansible and Terraform to work together (e.g., Terraform adds special tags to your servers and Ansible uses those tags to find the server and configure them). The major downside is that using Ansible typically means you’re writing a lot of procedural code, with mutable servers, so as your code base, infrastructure, and team grow, maintenance may become more difficult.

#### 2. Provisioning plus server templating
Example: Terraform and Packer. You use Packer to package your apps as virtual machine images. You then use Terraform to deploy (a) servers with these virtual machine images and (b) the rest of your infrastructure, including the network topology (i.e., VPCs, subnets, route tables), data stores (e.g., MySQL, Redis), and load balancers.

This is also an easy approach to start with, as there is no extra infrastructure to run (Terraform and Packer are both client-only applications). Moreover, this is an immutable infrastructure approach, which will make maintenance easier. However, there are two major drawbacks. First, virtual machines can take a long time to build and deploy, which will slow down your iteration speed. Second, the deployment strategies you can implement with Terraform are limited (e.g., you can’t implement blue-green deployment natively in Terraform), so you either end up writing lots of complicated deployment scripts, or you turn to orchestration tools, as described next.

#### 3. Provisioning plus server templating plus orchestration
Example: Terraform, Packer, Docker, and Kubernetes. You use Packer to create a virtual machine image that has Docker and Kubernetes installed. You then use Terraform to deploy (a) a cluster of servers, each of which runs this virtual machine image and (b) the rest of your infrastructure, including the network topology (i.e., VPCs, subnets, route tables), data stores (e.g., MySQL, Redis), and load balancers. Finally, when the cluster of servers boots up, it
forms a Kubernetes cluster that you use to run and manage your Dockerized applications.

The advantage of this approach is that Docker images build fairly quickly, you can run and test them on your local computer, and you can take advantage of all the built-in functionality of Kubernetes, including various deployment strategies, auto healing, auto scaling, and so on. The drawback is the added complexity, both in terms of extra infrastructure to run (Kubernetes clusters are difficult and expensive to deploy and operate, though most major cloud
providers now provide managed Kubernetes services, which can offload some of this work), and in terms of several extra layers of abstraction (Kubernetes, Docker, Packer) to learn, manage, and debug.





## ...

## TODO

 * Load Balancing Strategies with NGINX/HAProxy and Consul: https://www.youtube.com/watch?v=ZvKPAug-IgA
 * How Consul Eliminates the Need for East-West Load Balancers: https://www.youtube.com/watch?v=Ztq6miAqucU
   * AFAIK Consul is mainly used for East-West LB but can it also be used for North-South traffic? Or is Nginx, HAProxy etc still the better option for that?