# Ansible



## Systemd vs Service
 * Controls services on remote hosts. Supported init systems include `BSD init, OpenRC, SysV, Solaris SMF, systemd, upstart`.
 * This module acts as a proxy to the underlying service manager module. While all arguments will be passed to the underlying module, **not all modules support the same arguments**. This documentation only covers the minimum intersection of module arguments that all service manager modules support.
 * For instance docker does not use `systemd`, therefore you cannot use that module and need to use `service` instead


## Handler call order
Handlers are executed **in the order they are written in the handlers file, not the order they are notified**. 

In the example below, if the `reloaded systemd` handler was written/implemented after `restarted varnish` in the handlers file, then this step might fail.
Because the new systemd service file for varnish won't be seen by systemctl and it will still use the 'default' `/lib/systemd/system/varnish.service` (which has a different configuration) when `systemctl start varnish` is called
A `systemctl daemon-reload` needed in order for systemctl to use/see the new service file.

```yml
- name: "Create systemd file"
  template:
    src: etc/systemd/system/varnish.service.j2
    dest: /etc/systemd/system/varnish.service
    owner: root
    group: root
    mode: 0644
  notify:
    - reloaded systemd
    - restarted varnish
```

## Copying files and relative file paths
You don't have to provide a full path or relative path when you want to copy a file from your `files` directory to somewhere. Ansible will pick `foo.conf` automatically from the `files` directory of the role.

```yml
- copy:
    src: foo.conf
    dest: /etc/foo.conf
```

TODO - what about files in other directories? like templates etc?