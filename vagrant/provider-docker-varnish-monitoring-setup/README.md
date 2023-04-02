# TODO


## Requirements
The docker-compose plugin needs to be installed on the host machine: `vagrant plugin install vagrant-docker-compose`.

## Only build and deploy the jar
    cd ~/develop/personal/ci-cd-examples/varnish/varnish-demo-app && \
    mvn clean install && \
    cp target/varnish-demo-app-0.0.1-SNAPSHOT.jar ../../vagrant/provider-docker-varnish-monitoring-setup/ansible/roles/backend/files/varnish-demo-app-0.0.1-SNAPSHOT.jar && \
    cd ~/develop/personal/ci-cd-examples/vagrant/provider-docker-varnish-monitoring-setup/ansible
    ansible-playbook playbook.yml -i ./inventory.ini --tags=backend_deployment

## Run / Test 
Run `vagrant up` to start all VMs.
Run `vagrant reload` to reload the changed config in `Vagrantfile`.
Run `vagrant provision` to run any configured provisioners against the running Vagrant managed machine.
Run `vagrant global-status` to see which VMs are running.
Run `vagrant destroy -f` to stop and delete both containers.

How many threads does a process use: `ps -o thcount <pid>`

Test if everything works fine:
 * **Prometheus targets**: `http://localhost:9091/targets` -> you should see 4 `UP` states
 * **Grafana**: `http://localhost:3001` -> credentials `admin:admin`
 * **Node Exporter Endpoint**: `http://localhost:9101/metrics`
 * **Custom Varnish exporter**: `http://localhost:8001/` -> you should see some metrics with `myapp_` prefix
 * **Varnish exporter**: `http://localhost:9131/metrics` -> you should see a lot of metrics with `varnish_` prefix
 * **Demo Java application**: `http://localhost:2221`
 * **Demo Java application - metrics**: `http://localhost:2221/metrics`
 * **Varnish Endpoint**: `http://localhost:8061`
 * **Spring Actuator Prometheus Endpoint**: `http://localhost:2221/actuator/prometheus`
 * Connect to virtual machine 1: `vagrant ssh vm1` and make sure you have varnish 6.0 installed: `varnishd -V`

## Setup Dashboards
 1. JVM Micrometer: just copy paste id https://grafana.com/grafana/dashboards/4701-jvm-micrometer/


## TODOs
 * also import a simple JSON dashboard with ansible (maybe for our custom_varnish_exporter) so on startup we have a dashboard ready?
  * https://github.com/jonnenauha/prometheus_varnish_exporter/blob/master/dashboards/jonnenauha/dashboard.json
 * varnish in container is problematic, should install it directly on host so the python script has access to the logs
 * also create a load-test script?