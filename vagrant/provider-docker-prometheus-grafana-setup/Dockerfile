# Docker image to use with Vagrant
# Aims to be as similar to normal Vagrant usage as possible
# Adds Ansible, SSH daemon, Systemd
# Adapted from https://github.com/BashtonLtd/docker-vagrant-images/blob/master/ubuntu1404/Dockerfile

# TODO ubuntu:22.04 gives error "Vagrant ssh authentication failure"
FROM ubuntu:20.04

ENV container docker
ENV LANG=en_US.UTF-8
# Avoiding user interaction with tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies, you may not need all of these
RUN apt-get update -y \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
                    ssh \
                    sudo \
                    libffi-dev \
                    systemd \
                    openssh-client \
                    ansible \
                    openjdk-17-jdk-headless \
                    maven \
                    curl \
                    debianutils \
                    git \
                    jq \
                    rsync \
                    wget \
    && apt-get clean

# Needed to run systemd
# VOLUME [ "/sys/fs/cgroup" ]
# Doesn't appear to be necessary? See comments

# Add vagrant user and key for SSH
RUN useradd --create-home -s /bin/bash vagrant
RUN echo -n 'vagrant:vagrant' | chpasswd
RUN echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant
RUN chmod 440 /etc/sudoers.d/vagrant
RUN mkdir -p /home/vagrant/.ssh
RUN chmod 700 /home/vagrant/.ssh
ADD https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant:vagrant /home/vagrant/.ssh
RUN sed -i -e 's/Defaults.*requiretty/#&/' /etc/sudoers
RUN sed -i -e 's/\(UsePAM \)yes/\1 no/' /etc/ssh/sshd_config

# Start SSH
RUN mkdir /var/run/sshd
EXPOSE 22
RUN /usr/sbin/sshd

# Start Systemd (systemctl)
CMD ["/lib/systemd/systemd"]
