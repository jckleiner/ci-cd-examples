
 * Module creation recommended patterns: https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation

Multipe state files per environment:
A drawback with this approach is that it’s easy for differences to creep into environments. Someone might be in a rush, and make a change to the production environment without testing it in staging first. Even if it works OK, they might forget to back-port their changes to the staging environment files. These differences have a way of accumulating to the point where people no longer trust that staging really looks like production. It should be possible to wipe out staging and copy the current production files to refresh staging, but this can get messy with larger teams and codebases.

## Managing Multiple Environments in AWS

There are baaaasically three patterns that people use to manage multiple environments in AWS these days:

 1. **One AWS billing account and one flat network (VPC or Classic)**, with isolation performed by routes or security groups.
 2. **Many AWS accounts with consolidated billing**.  Each environment is a separate account (often maps to one acct per customer).
 3. **One AWS billing account and many VPCs**, where each environment ~= its own VPC.
