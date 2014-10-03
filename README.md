make-server
===========
Files for making servers with Ansible, Vagrant and serverspec.

サーバの構成管理を目的として、AnsibleとVagrantとserverspecのファイルを管理できる
かもしれない何かです。

## Setup

    $ mkdir -p ~/var/rhosts/
    $ cd ~/var/rhosts
    $ git clone https://github.com/azumakuniyuki/make-server.git
    ...

If you want to use other directory, edit Makefile and change the value of EXAMPLE
macro.

~/var/rhosts以外のディレクトリを使う場合はMakefileのEXAMPLEマクロを直してください。

## Make node
In this file, you build some web servers and a mail server of example.jp domain.

ここではexample.jp配下のWebサーバ数台とメールサーバを構築・構成管理することにします。

    $ mkdir -p ~/var/rhosts/example.jp
    $ cd ~/var/rhosts/example.jp
    $ cp ../make-server/Makefile ./

    $ vi ansible/product
    [product]
    www[01:25].example.jp
    mail.example.jp

    [webservers]
    www[01:25].example.jp

    [mailservers]
    mail.example.jp

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
    if [ ! -f "./Vagrantfile" ]; then \
        ...
    `vagrantup.com` for more information on using Vagrant.
    mkdir -p ./ansible
    make common-role
    ...
    $ make up
    ==> default: Importing base box 'centos64-x86_64'...
    Progress: 50%
    ...

## Copy roles

    $ cd ~/var/rhosts/example.jp
    $ make nginx-role sendmail/system-role mysql-5.5-role
    ...

When `make apache-role` executed, roles/apache will be copied from
make-server/ansible/roles directory to current `ansible/` directory if 
roles/apache exists in this repository. 

However, when make-server/ansible/roles/apache does not exist, only directory
tree will be created in ./ansible/roles directory followed Best Practices.

`make apache-role`を実行すると、このリポジトリにansible/roles/apacheがある場合は
それがコピーされ、無ければBest Practicesに従ったディレクトリ構造だけを作ります。

## List of files in make-server

|   Filename        |   Description                             |
|-------------------|-------------------------------------------|
| Makefile          | Shortcuts for ansible and vagrant command |
| README.md         | This file                                 |
| Vagrantfile       | Template file for sandbox vm              |
| ansible/          | Files for ansible                         |
|   hosts           | Inventory file for sandbox(Vagrant VM)    |
|   install         | Inventory file for initializing as root   |
|   develop         | Inventory file for development            |
|   staging         | Inventory file for staging servers        |
|   product         | Inventory file for production servers     |
|   10-build-stage  | Playbook for installing Python 2.7        |
|   20-deploy-user  | Playbook for creating user "deploy"       |
|   21-enable-epel  | Playbook to enable EPEL repository        |
|   30-update-sshd  | Playbook for changing sshd port           |
|   49-make-sslkey  | Playbook for generating key,csr,and crt   |
|   50-make-server  | Playbook for making servers               |
|   config          | Ansible configuration file for this node  |
|   log             | Log file specified in ansible/config file |
|   role/           | Ansible roles                             |

REPOSITORY
----------
https://github.com/azumakuniyuki/make-server

AUTHOR
------
azumakuniyuki

