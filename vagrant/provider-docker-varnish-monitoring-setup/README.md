# TODO


## Requirements
The docker-compose plugin needs to be installed on the host machine: `vagrant plugin install vagrant-docker-compose`.

## Run / Test 
Run `vagrant up` to start all VMs.
Run `vagrant reload` to reload the changed config in `Vagrantfile`.
Run `vagrant global-status` to see which VMs are running.
Run `vagrant provision` to run any configured provisioners against the running Vagrant managed machine.
Run `vagrant destroy -f` to stop and delete both containers.

Test if everything works fine:
 * Go to `http://localhost:9091/targets` -> you should see 3 `UP` states
 * Go to `http://localhost:3001` -> credentials `admin:admin` -> TODO


## TODOs
 * also import a simple JSON dashboard with ansible (maybe for our custom_varnish_exporter) so on startup we have a dashboard ready?
 * varnish in container is problematic, should install it directly on host so the python script has access to the logs
 * also create a load-test script?