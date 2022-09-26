# Ansible



## Systemd vs Service
 * Controls services on remote hosts. Supported init systems include `BSD init, OpenRC, SysV, Solaris SMF, systemd, upstart`.
 * This module acts as a proxy to the underlying service manager module. While all arguments will be passed to the underlying module, **not all modules support the same arguments**. This documentation only covers the minimum intersection of module arguments that all service manager modules support.
 * For instance docker does not use `systemd`, therefore you cannot use that module and need to use `service` instead



