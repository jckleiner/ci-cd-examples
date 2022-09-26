# Vagrant

## Running Vagrant on an M1 mac using Docker as the provider
[provider-docker-multi-machine-setup](./provider-docker-multi-machine-setup): Multi-machine Vagrant setup using Docker as the provider. This can be used on M1 Macs, since they can't use Virtualbox.

## Running Vagrant on an M1 mac using the Vagrant VMWare provider
https://gist.github.com/sbailliez/f22db6434ac84eccb6d3c8833c85ad92

Vagrant 2.2.19 did not work for me as well, I had to remove the current installation and then install 2.2.18: `brew install vagrant@2.2.18`
