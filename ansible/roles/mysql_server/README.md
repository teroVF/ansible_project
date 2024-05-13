Mysql_server role
=========

Installs mysql, its dependencies (pynthon libraries required) and configures a database, its connection and allowed user

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

The following variables can be customized to configure your MySQL server:

DB_PASS_ROOT: The root user’s password for MySQL.
DB_NAME: The desired name for the database you want to create.
DB_USER: The desired username for a new MySQL user.
DB_PASSWORD: The password for the new MySQL user.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------
---
- name: Configure MySQL Server
  hosts: localhost
  become: yes
  vars:
    DB_PASS_ROOT: "your_root_password"
    DB_NAME: "my_database"
    DB_USER: "my_user"
    DB_PASSWORD: "my_user_password"
  roles:
    - mysql_server

License
-------

BSD

Author Information
------------------

Role authors:
Antero (upsk14842976@iscte-iul.pt)
Miguel (upsk14082609@iscte-iul.pt)
Pedro Neves (upsk14420826@iscte-iul.pt)

https://github.com/teroVF/ansible_project
