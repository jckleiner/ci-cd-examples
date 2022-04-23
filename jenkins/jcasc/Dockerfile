FROM jenkins/jenkins:lts-jdk11

ARG DOCKER_GROUP_ID

# disable the jenkins GUI setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

ENV CASC_JENKINS_CONFIG /var/jenkins_home/configuration-as-code.yaml

USER root

# install additional packages
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    pip install jenkins-job-builder

USER jenkins

###### install ansible and docker ######
USER root

# RUN chown jenkins:jenkins /var/run/docker.sock
# RUN groupadd -g $DOCKER_GROUP_ID $DOCKER_GROUP_NAME && usermod -aG $DOCKER_GROUP_NAME jenkins

# RUN apt update && apt install -y ansible # installs ansbile 2.7
# Install ansible 2.9.24 - https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu bionic main" | tee -a /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
    apt update && \
    apt install -y ansible

# install docker
RUN apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt update && \
    apt install -y docker-ce && \
    usermod -aG docker jenkins && \
    usermod -aG docker root 
USER jenkins
###### / install ansible and docker ######

# install plugins
COPY plugins.yaml /usr/share/jenkins/ref/plugins.yaml
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.yaml

# copy the config for the Jenkins Configuration as Code Plugin
COPY --chown=jenkins:jenkins configuration-as-code.yaml /var/jenkins_home/configuration-as-code.yaml
ADD --chown=jenkins:jenkins example-jobs /var/jenkins_home/example-jobs
ADD --chown=jenkins:jenkins dockerfiles /var/jenkins_home/dockerfiles
ADD --chown=jenkins:jenkins logic /var/jenkins_home/logic

USER root

COPY --chown=jenkins:jenkins ./chown-of-docker-socket.sh .

ENTRYPOINT [ "./chown-of-docker-socket.sh" ]