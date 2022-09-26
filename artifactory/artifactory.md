
# Artifactory

> Currently does not work on an M1 Macbook because the artifactory docker image does not have an arm64 version.

Simple Docker Installation: https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory#InstallingArtifactory-DockerInstallation 
You need to setup these directories once:
 1. make sure you are inside the `artifactory` folder
 2. `mkdir -p ./var/etc`
 3. `touch ./var/etc/system.yaml`
 4. `sudo chown -R 1030:1030 ./var`
 5. `sudo chmod -R 777 ./var`

Artifactory has uses 2 ports:
 - `8081`: endpoint for deploying artifacts
 - `8082`: ui endpoint

## Setup
 1. Start Artifactory: `docker run --name artifactory -v ~/develop/personal/ci-cd-examples/artifactory/var:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-oss:latest`
 2. `http://localhost:8082` -> Default username: `admin`, Default password: `password`
 3. change your admin password (system forces you to do so). Change it to `Password1*`
 4. create a new user `ci-user` with a password `Password1*`

### Manual Setup
 1. create 2 `local repository`s -> Maven. `artifactory-maven-release` and `artifactory-maven-snapshot`
 2. in settings one should have `Handle Snapshots` checked and the other `Handle Releases`
 3. (Optional) You can also set `Max Unique Snapshots` for your snapshot repo, so it won't keep many unused artifacts

## Configuration as code
You can provide YAML configuration files which will be used to set up the system during startup.

 * See the documentation: https://www.jfrog.com/confluence/display/JFROG/System+YAML+Configuration+File

JFrog provides a flexible way to configure your system using a single `system.yaml` configuration file found in the `$JFROG_HOME/<product>/var/etc` folder. You can set up your system configuration in a single config file and provide that file as an input to your server as you deploy the server. The configuration files allow you to manage several aspects of your system, including resources, security settings, databases, and external connections.

Configuration values are applied according to the following hierarchy:

 1. Environment variables (`.env` file in case of Docker and Docker-Compose). if there are no variables, move to the next values
 2. `system.yaml` service section, if nothing is found there, move to the next values
 3. `system.yaml` shared section, if nothing is found there, move to the next values
 4. Etc.

If the user does not set any values in any of the files above, the application will use the default settings of the application.

Once you have configured your YAML file to include all the configuration changes needed, you can apply them by **restarting the server**.

> **Take care when modifying Artifactory configurations**: Modifying the system configurations is an advanced feature. Since it is easy to overwrite configurations, it is strongly recommended backing up the configuration before making any direct changes, and taking great care when doing so.

### Changes during runtime
Once the system is running, you can use the REST-API to make changes by providing YAML config files. You can create new repositories, change the config or delete stuff. (See https://www.jfrog.com/confluence/display/JFROG/Artifactory+YAML+Configuration)

This can be done by sending a PATCH request to `<host>:<port>/api/system/configuration`. You must supply a user with Admin privileges through the REST API.

For example:
	curl -u <username>:<password> -X PATCH "http://localhost:8081/artifactory/api/system/configuration" -H "Content-Type: application/yaml" -T configuration.yml

Use the following curl command to setup our 2 repositories: `curl -u 'admin':'Password1*' -X PATCH "http://localhost:8081/artifactory/api/system/configuration" -H "Content-Type: application/yaml" -T ./config/local-repository-config.yml`

Get the configuration as XML: `curl -u 'admin':'Password1*' -X GET "http://localhost:8081/artifactory/api/system/configuration"`

System configuration with YAML: https://www.jfrog.com/confluence/display/JFROG/Artifactory+System+YAML

## Deploy Locally
Deploy a local maven artifact to the local artifactory:
 1. cd into a maven project folder
 2. Add the `distributionManagement` snippet shown below to the pom
 3. run: `mvn -s ~/develop/personal/ci-cd-examples/artifactory/settings.xml clean deploy --fail-at-end --no-transfer-progress`

This snippet should be pasted to the `pom.xml`:
```xml
	<distributionManagement>
        <!-- 400 Bad Request will be returned if you attempt to:
            Deploy a snapshot artifact (version ending in -SNAPSHOT) to a release repository
            Deploy a release artifact (version not ending in -SNAPSHOT) to a snapshot repository
        -->
		<repository>
			<id>artifactory-maven-release</id>
			<url>http://localhost:8081/artifactory/artifactory-maven-release</url>
		</repository>
		<snapshotRepository>
			<id>artifactory-maven-snapshot</id>
			<url>http://localhost:8081/artifactory/artifactory-maven-snapshot</url>
		</snapshotRepository>
	</distributionManagement>
```

### Best Practices For Artifactory Repositories
https://jfrog.com/whitepaper/best-practices-structuring-naming-artifactory-repositories/

TODO best practices for naming repositories

TODO best practices for permissions/groups

## Snapshot vs Release Repositories
Release repositories hold releases and Snapshot repositories hold snapshots (wow).
 * A **snapshot** is defined as an artifact with a version ending in `-SNAPSHOT`, for example having `<version>1.0-SNAPSHOT</version>` in your pom will result in an artfact like `hello-app-1.0-SNAPSHOT.jar`. Snapshots is the special version that indicates current deployment copy and not a regular, specific version.
 * A **release** artifact is an artifact which does not end in `-SNAPSHOT`.
`<version>1.0</version>` will create `hello-app-1.0.jar`

> You can write anything as a version, it does not need to be a number like 1.0.4 (this way of versioning your artifacts is called semantic versioning). For example, you can also version your artifacts like `PROD-20220408_1402`, `TEST-20220408_1402` and so on.

## How Artifactory Handles Artifacts
In Artifactory, a local repository can be a `Snapshot Repository` and also a `Release Repository` at the same time, if you chose so.
> But it is good practice to have 2 different repositories for each.

Your deployment might fail if you try to:
 - Deploy a snapshot artifact (version ending in -SNAPSHOT) to a release repository
 - Deploy a release artifact (version not ending in -SNAPSHOT) to a snapshot repository

> There can be multiple versions (with different timestamps) of a snapshot version in a snapshot repository but only one release version.

As an example, if you deploy a snapshot, artifactory will automatically add a timestamp to the files. If you pushed multiple snapshot artifacts with the version `1.0-SNAPSHOT`, they will land in the same `com/example/hello-app/1.0-SNAPSHOT` "folder" with following names (as an example):
 * notion-backup-1.0-20220408.094702-1.jar
 * notion-backup-1.0-20220408.094902-1.pom
 * notion-backup-1.0-20220408.094902-2.jar
 * notion-backup-1.0-20220408.094702-2.pom
 * notion-backup-1.0-20220408.095122-3.jar
 * notion-backup-1.0-20220408.095122-3.pom

And when you pull the `1.0-SNAPSHOT` artifact from that snapshot repository, you will get the latest version.

## Snapshot Cleanup
In a snaphot repository, you can set the `Max Unique Snapshots` setting.
Every time you deploy a snapshot, Artifactory will check the value `Max Unique Snapshots` for the repository, and if exceeded will mark any excess old snapshots for deletion. Then, **every 5 minutes**, Artifactory runs a background process that deletes those oldest snapshots that have been marked. For example, if you set Max Unique Snapshots to 5 and deploy a sixth and seventh snapshot to the repository, then next time the background process runs, it will delete the two oldest snapshots.

## Deploying Release Artifacts
Unlike snapshot artifacts, there is always only one version of a release artifact version, if you push a version, for example `1.0`, the jar will go to the `com/example/hello-app/1.0` folder and there will only be one jar in there.

If you push the same version again, it will give you a success response but **it does not override the files, if the same version is already present**

## Todos
 - How to setup permissions, groups and users with `system.yml`?
 - Permissions and groups
 - pulling release artifacts, if you don't give a version, it pulls the latest?

`docker stop artifactory && docker rm artifactory`
`docker run --name artifactory -v ~/develop/personal/ci-cd-examples/artifactory/var:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-oss:latest`

Check version and other infos (needs admin account): http://localhost:8081/artifactory/api/system/version