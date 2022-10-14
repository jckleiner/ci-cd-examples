# Vagrant

## Virtualization/Emulation on M1
**Virtualization**: the guest and host OS have the same architecture.
**Emulation**: the guest and host OS have different architectures. It is much slower compared to virtualization

This video compares different virtualization options for M1:
https://www.youtube.com/watch?v=uRwnwkdSX-I

## Running Vagrant on an M1 mac using Docker as the provider
[provider-docker-multi-machine-setup](./provider-docker-multi-machine-setup): Multi-machine Vagrant setup using Docker as the provider. This can be used on M1 Macs, since they can't use Virtualbox.

## Running Vagrant on an M1 mac using the Vagrant VMWare provider
[provider-vmware](./provider-vmware/): Uses VMWare as a provider and requires arm64 boxes
