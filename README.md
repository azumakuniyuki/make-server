make-server
===========
Files for making servers with Ansible, Vagrant and serverspec.

## Setup

    $ mkdir -p ~/var/rhosts/
    $ cd ~/var/rhosts
    $ git clone https://github.com/azumakuniyuki/make-server.git
    ...

If you want to use other directory, edit Makefile and change the value of EXAMPLE
macro.

## Make node

    $ mkdir -p ~/var/rhosts/example.jp
    $ cd ~/var/rhosts/example.jp
    $ cp ../make-server/Makefile ./

## Prepare Vagrant vm as a sandbox

    $ cd ~/var/rhosts/example.jp
    $ make list
    vagrant box list
    centos56-i386    (virtualbox)
    centos64-x86_64  (virtualbox)
    centos65-x86_64  (virtualbox)
    freebsd92-i386   (virtualbox)
    openbsd53-x86_64 (virtualbox)

    $ make centos64-x86_64-box ansible
    $ make up
    vagrant up
    Bringing machine 'default' up with 'virtualbox' provider...
    ==> default: Clearing any previously set forwarded ports...
    ==> default: Clearing any previously set network interfaces...
    ...

## List of files in make-server

|   Filename        |   Description 
|   --------        |   -----------     |
| Makefile          | Shortcuts for ansible, serverspec, and vagrant command |
| README.md         | This file |
| Vagrantfile       | Template file for sandbox vm |
| ansible/          | Include files for ansible |
| ansible/hosts     | Inventory file for sandbox(Vagrant VM) |
| ansible/develop   | Inventory file for development |
| ansible/staging   | Inventory file for staging servers |
| ansible/product   | Inventory file for production servers |
| ansible/config    | Ansible configuration file for this node |
| ansible/log       | Log file specified in ansible/config file |
| ansible/role/     | Ansible roles |


