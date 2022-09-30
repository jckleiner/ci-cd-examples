# GitHub Actions
A platform to automate **developer workflows**. It's <u>not just a CI/CD pipeline</u>. CI/CD workflows is just one of the many workflows that you can automate with GitHub Actions.

## Workflows Overview
A workflow is a configurable automated process that will run one or more jobs. Workflows are defined by a YAML file checked in to your repository and will run when triggered by an event in your repository, or they can be triggered manually, or at a defined schedule.

Workflows are defined in the `.github/workflows` directory in a repository (each workflow is stored as a separate YAML file), and a repository can have multiple workflows, each of which can perform a different set of tasks. For example, you can have one workflow to build and test pull requests, another workflow to deploy your application every time a release is created, and still another workflow that adds a label every time someone opens a new issue.

A workflow must contain the following basic components:
 1. One or more events that will trigger the workflow.
 2. One or more jobs, each of which will execute on a runner machine and run a series of one or more steps.
 3. Each step can either run a script that you define or run an action, which is a reusable extension that can simplify your workflow.

Workflow triggers are events that cause a workflow to run. These events can be:
 * Events that occur in your workflow's repository
 * Events that occur outside of GitHub and trigger a `repository_dispatch` event on GitHub
 * Scheduled times
 * Manual

By default:
 * `whoami` is `runner`
 * `pwd` is `/home/runner/work/<repo-name>/<repo-name>`
 * ubuntu has `docker` and `docker-compose` pre-installed
 * jobs run in parallel and the environment is the same but no folders are shared between jobs.

### Structure of Workflows
```YAML
# Optional - The name of the workflow as it will appear in the "Actions" tab of the GitHub repository. 
name: learn-github-actions

# Optional - The name for workflow runs generated from the workflow, which will appear in the list of workflow runs on your repository's "Actions" tab. 
# This example uses an expression with the github context to display the username of the actor that triggered the workflow run.
run-name: ${{ github.actor }} is learning GitHub Actions

# Specifies the trigger for this workflow. This example uses the push GitHub event, so a workflow run is triggered every time someone pushes a change to the repository 
# or merges a pull request. This is triggered by a push to every branch; you can also run only on pushes to specific branches, paths, or tags
on: [push]

# Groups together all the jobs that run in the learn-github-actions workflow.
jobs:
    # Defines a job named "check-bats-version". The child keys will define properties of the job. 
    check-bats-version:
        # Configures the job to run on the latest version of an Ubuntu Linux runner. This means that the job will execute on a fresh virtual machine hosted by GitHub.
        runs-on: ubuntu-latest
        # Optionally you can set the environment for each job
        environment: test-env
        # Groups together all the steps that run in the check-bats-version job. Each item nested under this section is a separate action or shell script. 
        steps:
            # The uses keyword specifies that this step will run v3 of the "actions/checkout" action. This is an action that checks out your repository onto the runner,
            # allowing you to run scripts or other actions against your code (such as build and test tools). 
            # You should use the checkout action any time your workflow will run against the repository's code. 
            - uses: actions/checkout@v3
            # This step uses the "actions/setup-node@v3" action to install the specified version of the Node.js. This puts both the node and npm commands in your PATH. 
            - uses: actions/setup-node@v3
              with:
                  node-version: '14'
            # The run keyword tells the job to execute a command on the runner. In this case, you are using npm to install the bats software testing package. 
            - run: npm install -g bats
            # Finally, you'll run the bats command with a parameter that outputs the software version. 
            - run: bats -v
```

### Storing Secrets
If your workflows use sensitive data, such as passwords or certificates, you can save these in GitHub as secrets and then use them in your workflows as environment variables.
If your secrets are printed to stdout, the console won't show the values. Instead you will see `***`.
There are 3 types of secrets in GitHub:
 1. **Organization Secrets**: Secrets created on an organizations page. These are globally available in your workflows, accessed like this `${{secret.REPO_SECRET}}`. Not available with the free plan. Effectively becomes repository secrets.
 2. **Repository secrets** (Settings > Secrets > Actions > new repository secret): these are globally available in your workflows, accessed like this `${{secret.REPO_SECRET}}`
    ```YAML
    jobs:
    example-job:
        runs-on: ubuntu-latest
        steps:
        - name: Set secrets as an environemnt variable
            env:
            my_secret: ${{ secrets.REPO_SECRET }}
            run: |
            echo "My secret is: $my_secret"

        - name: Or write the secret value directly
            run: |
            echo "My secret is: ${{ secrets.REPO_SECRET }}"
            
        - uses: test/some-action@v1
            with:
            first_parameter: ${{ secrets.REPO_SECRET }}
            environment: |
            ENV_VAR_1=${{ secrets.REPO_SECRET }}
    ```
 3. **Environment secrets** (Settings > Environments > New Environment > ... > add secret): Only available when you use that particular environment in a job.
    In this example `TEST_ENV_SECRET` is only accessible if the job uses `environment: test-env`
    ```YAML
    jobs:
      build-job:
        environment: test-env
        runs-on: ubuntu-latest
        steps:
          - name: Run a one-line script
            run: echo "My secret: ${{ secrets.TEST_ENV_SECRET }}"
    ```

Order of precedence for secrets:
  1. Environment secrets
  2. Repository secrets
  3. Organization secrets

### Creating dependent jobs
By default, the jobs in your workflow **all run in parallel**. 
 * Each job runs in a **separate runner environment** specified by `runs-on`.
If you have a job that must only run after another job has completed, you can use the `needs` keyword to create this dependency. If one of the jobs fails, all dependent jobs are skipped; however, if you need the jobs to continue, you can define this using the `if` conditional statement.

```YAML
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - run: ./setup_server.sh
  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - run: ./build_server.sh
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: ./test_server.sh
  # This job will always run after 'build' and 'test' jobs were finished, regardless of their return status
  deploy:
    if: ${{ always() }}
    needs: [build, test]
```

### Caching dependencies
If your jobs regularly reuse dependencies, you can consider caching these files to help improve performance. Once the cache is created, it is <u>available to all workflows in the same repository</u>.
Workflow runs often reuse the same outputs or downloaded dependencies from one run to another. For example, package and dependency management tools such as Maven, Gradle, npm, and Yarn keep a local cache of downloaded dependencies. Jobs on GitHub-hosted runners start in a clean runner image and must download dependencies each time, causing increased network utilization, longer runtime, and increased cost.

To cache dependencies for a job, you can use GitHub's **`cache` action**. The action creates and restores a cache identified by a unique key. Alternatively, if you are caching the package managers listed below, using their respective setup-* actions requires minimal configuration and will create and restore dependency caches for you.

 * npm, Yarn, pnpm	        setup-node
 * pip, pipenv, Poetry	    setup-python
 * Gradle, Maven	        setup-java
 * RubyGems	                setup-ruby
 * Go go.sum	            setup-go

> Warning: Be mindful of the following when using caching with GitHub Actions:
> * We recommend that you don't store any sensitive information in the cache. For example, sensitive information can include access tokens or login credentials stored in a file in the cache path. Also, command line interface (CLI) programs like docker login can save access credentials in a configuration file. <u>Anyone with read access can create a pull request on a repository and access the contents of a cache. Forks of a repository can also create pull requests on the base branch and access caches on the base branch</u>.
> * When using self-hosted runners, caches from workflow runs are <u>stored on GitHub-owned cloud storage</u>. A customer-owned storage solution is only available with GitHub Enterprise Server.

### Storing workflow data as artifacts / Passing data between jobs
Artifacts allow you to share data between jobs in a workflow and store data once that workflow has completed.
An artifact is a file or collection of files produced during a workflow run. For example, you can use artifacts to save your build and test output after a workflow run has ended. All actions and workflows called within a run have write access to that run's artifacts.

By default, GitHub stores build logs and artifacts for **90 days**, and this retention period can be customized. The retention period for a pull request restarts each time someone pushes a new commit to the pull request.

Storing artifacts uses storage space on GitHub. GitHub Actions usage is free for standard GitHub-hosted runners in public repositories, and for self-hosted runners. For private repositories, each GitHub account receives a certain amount of free minutes and storage for use with GitHub-hosted runners, depending on the product used with the account. Any usage beyond the included amounts is controlled by spending limits.

Artifacts are uploaded during a workflow run, and you can view an artifact's name and size in the UI. When an artifact is downloaded using the GitHub UI, all files that were individually uploaded as part of the artifact get zipped together into a single file. This means that billing is calculated based on the size of the uploaded artifact and not the size of the zip file.

GitHub provides two actions that you can use to upload and download build artifacts, `actions/upload-artifact` and `actions/download-artifact`.

To share data between jobs:
 * **Uploading files**: Give the uploaded file a name and upload the data before the job ends.
 * **Downloading files**: You can only download artifacts that were uploaded <u>during the same workflow run</u>. When you download a file, you can reference it by name.

<u>The steps of a job share the same environment on the runner machine, but run in their own individual processes</u>. To pass data between steps in a job, you can use inputs and outputs. For more information about inputs and outputs, see "Metadata syntax for GitHub Actions."

**Artifacts vs Cache**: Artifacts and caching are similar because they provide the ability to store files on GitHub, but each feature offers different use cases and cannot be used interchangeably.

 * Use caching when you want to reuse files that don't change often between jobs or workflow runs, such as build dependencies from a package management system.
 * Use artifacts when you want to save files produced by a job to view after a workflow run has ended, such as built binaries or build logs.

```YAML
steps:
    upload:
      - name: Create file
        run: |
          echo "Hello, world!" > my-file.txt
          
      - name: Archive my-file
        uses: actions/upload-artifact@v3
        with:
          name: my-file.txt
          retention-days: 5
          path: |
            ./my-file.txt
            !dist/**/*.md

  print:
    runs-on: ubuntu-latest
    needs: upload
    steps:
      - name: Download my-file.txt
        uses: actions/download-artifact@v3
        with:
          name: my-file.txt
          # Optional - you can only specify a folder. If a folder is not present, it will be created.
          path: ./folder1
      
      # prints "Hello, world!"
      - run: cat ./folder1/my-file.txt 
```

Each workflow run will create and store the `my-file.txt` file and if not specified, the retention period is 90 days.
So you should be careful and try to set a low `retention-days` value so that unused artifacts are deleted quickly.

## Evolution of CI/CD platforms
In this codecentric [blog article](https://blog.codecentric.de/github-actions-nextgen-cicd), Jonas argues that there were roughly 3 distinct steps in the life of CI/CD platforms:
 1. **The first wave (Hudson/Jenkins)**: The beginning of CI/CD tools, when you still wrote a lot of imperative code without the "pipeline as code" idea. 
 2. **The second wave (TravisCI/GitLabCI)**: TravicCI was one of the first which simpified the pipeline code. "Declarative pipelines" were introduced and got popular. 
    Jenkins introduced the Jenkins Job DSL plugin and later Jenkins 2.0 Pipelines which allowed you to write pipelines as code. GitLabCI introduced the `include` keyword into their pipeline syntax.Now it was possible to write re-usable pipeline templates in an elegant way.
 3. **The third wave (GitHub Actions)**: At the end of 2019 GitHub introduced Actions. It's marketplace lists many actions provided by GitHub itself, or they are developed by other companies and the community. These actions can then be used as building blocks in your pipelines, which further reduces the lines of code needed to be written by you.

**Pipeline as Code**: Pipeline as code is a practice of defining deployment pipelines through source code, such as Git. Pipeline as code is part of a larger “as code” movement that includes infrastructure as code. Teams can configure builds, tests, and deployment in code that is trackable and stored in a centralized source repository. Teams can use a declarative YAML approach or a vendor-specific programming language, such as Jenkins and Groovy, but the premise remains the same.



# TODOs
 * How does versions work? my-action@v3 -> does this use the latest 3.x.x?
 * Create Your Own GitHub Actions: https://www.youtube.com/watch?v=jwdG6D-AB1k
 * Nested folders in workflows folder?
 * Setup your own runner with Docker?
   * GitHub Actions Self Hosted Runner (Autoscaling with Kubernetes): https://www.youtube.com/watch?v=lD0t-UgKfEo&t=295s
 * learn more about caching
 * Learn more (and maybe document) about signing containers: https://www.youtube.com/watch?v=OqZlKbTRWOY