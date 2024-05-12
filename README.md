#Ansible Project

This project is a example of how to use Ansible to automate the deployment and configuration of a web application, in this case a simple wordpress site aswell to install updates and create users on different operative systems. 

The project is part of the Ansible module in the Upskill formation for SysAdmins.

It is asked by the trainer (Tiago Bernardo) to use ansible and to: 

- Configure 3 servers (database, web server and windows server) in two distinct environments (production and disaster recovery)
- Install and configure all necessary dependencies and software to put online and in a working state the wordpress site
- Create two main playbooks: One to update all the machines and another to create users and groups

We use terraform to create the infrastructure on azure and on ansible to deploy all the users and configuration needed to comply with the previously mentioned requeriments

Playbooks and corresponding command that can be used:

To update all the machines you can use the following command:
ansible-playbook