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
    $ make up
    vagrant up
    Bringing machine 'default' up with 'virtualbox' provider...
    ==> default: Clearing any previously set forwarded ports...
    ==> default: Clearing any previously set network interfaces...
    ...

## Copy roles

    $ cd ~/var/rhosts/example.jp
    $ make apache-role sendmail-role mysql-role
    ...

When `make apache-role` executed, roles/apache will be copied from
make-server/ansible/roles directory to current `ansible/` directory if 
roles/apache exists in this repository. 

However, when make-server/ansible/roles/apache does not exist, only directory
tree will be created in ./ansible/roles directory followed Best Practices.

`make apache-role`を実行すると、このリポジトリにansible/roles/apacheがある場合は
それがコピーされ、無ければBest Practicesに従ったディレクトリ構造だけを作ります。

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

