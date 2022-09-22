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

<br><hr><br>

## Secret Management Problem
A secret in this context is anything that grants you autorization and or authentication.
Secrets management is the process of securely and efficiently managing the creation, rotation, revocation, and storage of digital authorization credentials. In a way, secrets management can be seen as an enhanced version of password management. While the scope of managed credentials is larger, the goal is the same — to protect critical assets from unauthorized access.

There are four main phases a password or other secret can go through:
 * Creation
 * Storage     
 * Rotation
 * **Revocation**: Being able to revoke user credentials is one of the key NIST requirements. Revoking secrets should be a standard response to an employee’s resignation, the expiration of an agreement with a third-party vendor, failed authorization attempts, etc.

In practice you see a **secret sprawl**, meaning that the secrets used in the systems are everywhere. In plain text inside of the source code, configuration management (ansible etc.), CI/CD server etc.
Some problems arises with this approach:
 * **No fine grained ability to give and audit the access**: We don't know who has access to our infrastructure. We don't know if someone has access to our GitHub and see our source code and therefore our secrets. Even if they could do it, we can't be sure if they have done it. No audit trail.
 * **No easy rotation**: It's difficult to rotate the secrets when they are so spread accross.

These 2 problems can be solved by centralizing the secrets.

In general, applications do a poor job keeping things secret. The credentials could be printed to stoud at some point and will end up in the logs somewhere in plain text for instance.

This can be solved by using dynamic secrets, short lived ephemeral secrets.
 * **Short lived (for example 30 days)**. Even if they leak to some other system, it will be not valid after some time.
 * **Each credential is unique to each client**. In our previous example, if we have 50 web servers who share the same DB credentials and the password leaks, its difficult to pin-point from where exactly the secret leaked out. If dynamic secrets were in use, each server would have a unique credential. So we would know exactly which server was compramised.
 * **Easy revocation**: Since now we know that the server 42 were compamised, it is super easy to revoke the credentials just for server 42. If each server used the same credentials, we had to change it and the entire system would have an outage. So the **blast radius** of a revocation is much larger if you have a shared secret vs a dynamic secret.

Hashicorp Vault provides also endpoints for you to do encryption so that the application doesnt need to implement all the details itself.

### Bad practices
Weak passwords.
Storing secrets in plain text
Sharing passwords
No secrets revocation
No secrets rotation
Reusing secrets: Using the same secret for different accounts, services, or applications

<br><hr><br>

## Deployment Strategies
There are a number of different strategies you can use for application deployment, depending on your requirements. Let’s say you have 5 copies of the old version of your app running and you want to roll out a new version. Here are a few of the most common strategies you can use:

 1. **Rolling deployment with replacement**: Take down 1 of the old copies of the app, deploy a new copy to replace it, wait for the new copy to come up and pass health checks, start sending the new copy live traffic, and then repeat the process until all the old copies have been replaced. Rolling deployment with replacement ensures that you never have more than 5 copies of the app running, which can be useful if you have limited capacity (e.g., if each copy of the app runs on a physical server), or if you’re dealing with a stateful system where each app has a unique identity (e.g., this is often the case with consensus systems, such as Apache ZooKeeper). Note that this deployment strategy can work with larger batch sizes (i.e., you can replace more than one copy of the app at a time, assuming you can handle the load and won’t lose data with fewer apps running) and that during deployment, you will have both the old and new versions of the app running at the same time.
 2. **Rolling deployment without replacement**: Deploy 1 new copy of the app, wait for the new copy to come up and pass health checks, start sending the new copy live traffic, undeploy an old copy of the app, and then repeat the process until all the old copies have been replaced. Rolling deployment without replacement works only if you have flexible capacity (e.g., your apps run in the cloud, where you can spin up new virtual servers any time you want) and if your application can tolerate more than 5 copies of it running at the same time. The advantage is that you never have less than 5 copies of the app running, so you’re not running at a reduced capacity during deployment. Note that this deployment strategy can work with larger batch sizes (i.e., you can deploy 5 new copies simultaneously) and that during deployment, you will have both the old and new versions of the app running at the same time.
 3. **Blue-green deployment**: Deploy 5 new copies of the app, wait for all of them to come up and pass health checks, shift all live traffic to the new copies, and then undeploy the old copies. Blue-green deployment works only if you have flexible capacity (e.g., your apps run in the cloud, where you can spin up new virtual servers any time you want) and if your application can tolerate more than 5 copies of it running at the same time. The advantage is that only one version of your app is visible to users at any given time, and that you never have less than 5 copies of the app running, so you’re not running at a reduced capacity during deployment.
 4. **Canary deployment**: Deploy 1 new copy of the app, wait for it to come up and pass health checks, start sending live traffic to it, and then pause the deployment. During the pause, compare the new copy of the app, called the “canary,” to one of the old copies, called the “control.” You can compare the canary and control across a variety of dimensions: CPU usage, memory usage, latency, throughput, error rates in the logs, HTTP response codes, and so on. Ideally, there’s no way to tell the two servers apart, which should give you confidence that the new code works just fine. In that case, you unpause the deployment, and use one of the rolling deployment strategies to complete it. On the other hand, if you spot any differences, then that may be a sign of problems in the new code, and you can cancel the deployment and undeploy the canary before the problem gets worse.

<br><hr><br>

## ...

## TODO

 * Load Balancing Strategies with NGINX/HAProxy and Consul: https://www.youtube.com/watch?v=ZvKPAug-IgA
 * How Consul Eliminates the Need for East-West Load Balancers: https://www.youtube.com/watch?v=Ztq6miAqucU
   * AFAIK Consul is mainly used for East-West LB but can it also be used for North-South traffic? Or is Nginx, HAProxy etc still the better option for that?