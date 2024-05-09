Apache Role
=========

This role installs and configures the Apache web server to permit and host the wordpress website.

Requirements
------------

This role requires Ansible to be installed on the target system. Additionally, the target system should have internet access to download the necessary packages.

Role Variables
--------------

The following variables can be customized to configure the Apache web server:

- `apache_port`: The port on which Apache should listen. Default is 80.
- `apache_document_root`: The document root directory for the web server. Default is "/var/www/html".
- `apache_index_file`: The default index file for the web server. Default is "index.html".

Dependencies
------------

This role has no dependencies on other roles.

Example Playbook
----------------

Here's an example playbook that uses this role:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

Role authors:
Antero (upsk14842976@iscte-iul.pt)
Miguel (upsk14082609@iscte-iul.pt)
Pedro Mendes (upsk14420826@iscte-iul.pt)

https://github.com/teroVF/ansible_project
