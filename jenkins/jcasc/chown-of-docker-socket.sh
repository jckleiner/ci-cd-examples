#!/bin/sh

# TODO comment
chown jenkins:jenkins /var/run/docker.sock

# keep the container running: tail -f /dev/null

# the entrypoint in jenkins/jenkins:lts-jdk11
# ENTRYPOINT ["/sbin/tini" "--" "/usr/local/bin/jenkins.sh"]
/sbin/tini -- /usr/local/bin/jenkins.sh