# Ansible

## Systemd vs Service
 * Controls services on remote hosts. Supported init systems include `BSD init, OpenRC, SysV, Solaris SMF, systemd, upstart`.
 * This module acts as a proxy to the underlying service manager module. While all arguments will be passed to the underlying module, **not all modules support the same arguments**. This documentation only covers the minimum intersection of module arguments that all service manager modules support.
 * For instance docker does not use `systemd`, therefore you cannot use that module and need to use `service` instead


## Handler call order and execution time
Two important points to keep in mind about handlers:
 1. By default, handlers **run at the end of the play once all the regular tasks have been executed**. If you want handlers to run before the end of the play or between tasks, add a meta task to flush them using the meta module
 2. Handlers are executed **in the order they are written in the handlers file, not the order they are notified**. 

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

## Copying files - be aware
Consider the following example snippet:

```yml
- name: copy logrotate from cron.daily to cron.hourly dir
  copy:
    src: /etc/cron.daily/logrotate
    dest: /etc/cron.hourly
    remote_src: yes
```

Be aware of these different scenarios:

1.`src` is a file:
 * When you only give the `dest` folder name **without** a `/` at the end (`dest: /etc/cron.hourly`)
    * if `dest` points to an existing **folder** then the src file is copied inside
    * if `dest` points to an existing **file or does not exist**, then a **file** with the name `/etc/cron.hourly` is created (or replaced). In this case, all given folders in path `dest` must exist or else the step will fail.
 * When you only give the `dest` folder name **with** a `/` at the end (`dest: /etc/cron.hourly/`)
   * if `dest` does not exist, a new folder is created and the src file will be copies inside

2.`src` is a folder:
TODO - document, https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html#parameter-dest

## Copying files and relative file paths
You don't have to provide a full path or relative path when you want to copy a file from your `files` directory to somewhere. Ansible will pick `foo.conf` automatically from the `files` directory of the role.

```yml
- copy:
    src: foo.conf
    dest: /etc/foo.conf
```

TODO - what about files in other directories? like templates etc?

## Copy and Template modules and checksum
When you run `copy` or `template` steps, the step only executes when there the src file was actually changed.

I've tested some scenarios to make sure of the behaviour because I couldnt find detailed sources of documentation about this.
After the first provisioning run, when host and target machines had the files already there:
 * When I did `touch src`, meaning the jinja file (only changing the last-modified time and not the content) it **did not detected any changes** and continued without doing anything on the next run.
 * When I did `touch dest` (only changing the last-modified time and not the content) it **did not detected any changes** and continued without doing anything.
 * When I edited the contents of the `src` file, it detected the change and replaced the `dest` file (as expected).
 * When I edited the contents of the `dest` file, it detected the change and replaced the `dest` file.

When you enable verbose mode `vv`, you can see the the following (when there was no change detected):

    ok: [vm1] => {
      "changed": false,
      "checksum": "e199e409859e2c4cbb202756b0f3d3838d027b3e",
      "dest": "/etc/varnish/default.vcl",
      "gid": 0, "group": "root", "mode": "0644", "owner": "root", 
      "path": "/etc/varnish/default.vcl", 
      "size": 1468, 
      "state": "file", 
      "uid": 0
    }

`e199e409859e2c4cbb202756b0f3d3838d027b3e` is the `sha1` checksum of the generated file.
So it looks like Ansible **compares the files checksum** to determine if it should proceed with the step. The **file name and last-modified date is not relevant** in this case.

## ...