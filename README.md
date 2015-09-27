make-server
===========
make-server is something like a framework for management Ansible palybooks and
Serverspec test codes. This repository include some playboks and test codes in 
`server/` directory.

make-serverはAnsibleのPlaybookとServerspecのテストコードを管理するフレームワーク
的な何かです。リポジトリには幾つかのPlaybookとテストコードが入っています。

## Install | インストール
`make install` command will install `makeserverctl` command only into 
`/usr/local/bin` directory. If you want to install `makeserverctl` command into
the directory except `/usr/local`, specify `PREFIX` macro with `install` target.

```shell
% cd /usr/local/src
% git clone https://github.com/azumakuniyuki/make-server.git
% cd ./make-server

% sudo make install PREFIX=/usr/local
Password:
/usr/bin/make .make-server-directory
make[1]: `.make-server-directory' is up to date.
test -d bin && cd bin/ && /bin/make install
test -d /usr/local/bin || mkdir -p /usr/local/bin
install -o root -m 0755 makeserverctl /usr/local/bin

% hash -r
% which makeserverctl
/usr/local/bin/makeserverctl
```

`make install`を実行すると`makeserverctl`コマンドだけが`/usr/local/bin`に
インストールされます。`/usr/local`以外に`makeserverctl`コマンドをインストール
する場合は`PREFIX`マクロを`install`ターゲットに指定してください。

### makeserverctl Command | makeserverctlコマンド
`makeserverctl` command have the following features:

* Create directory tree for Ansible roles and Serverspec tests in the node directory
* Update Makefiles including Rakefile and .rspec at the node directory
* Generate shadow password string for /etc/passwd
* Features called from some targets defined in each Makefile in the node directory

```shell
% makeserverctl --help
/usr/local/bin/makeserverctl OPTIONS 
  --rootdir           : Print the distribution directory and exit
  --location          : Check current directory is distribution directory or not
                        This script exits at status 1 when here is distribution directory
  --setup             : Setting up Makefiles at current directory
  --update-makefile   : Update Makefiles in current directory
  --role-index        : Show available roles

/usr/local/bin/makeserverctl OPTIONS <plain-text>
  --shadow-passwd     : Create shadow password string
  -a, --algorithm <v> : Shadow password algorithm: MD5, SHA256, SHA512(default)

  --help              : Help screen
  --version           : Print the version number
  -v, --verbose       : Verbose mode
  --cpanm             : Find or download cpanm command
  --modules           : Print required perl module list
```

`makeserverctl`コマンドは以下の機能を持っています。

* ノードディレクトリにAnsibleのロール用・Serverspecのテスト用ディレクトリ構造を生成
* ノードディレクトリのRakefile,.rspecを含むMakefileのアップデート
* /etc/passwd用パスワードハッシュの生成
* ノードディレクトリ内にある各Makefileのターゲットから呼び出される機能がいくつか

## Make Node | ノードの作成
The following commands are example for creating directory tree to build 2 web
servers and 1 mail server at `example.jp` domain.  `makeserverctl --setup` 
command create the required directory tree and copy some Makefiles from the 
directory which is the result of `makeserverctl --rootdir` command to the 
`example.jp/` directory.

```shell
% mkdir -p /tmp/example.jp
% cd /tmp/example.jp
% makeserverctl --setup
 * debug1: Debug level = 1
 * debug1: Run mode = 5
 * debug1: make-server root directory = /usr/local/src/make-server
 * debug1: Destination directory = /tmp/example.jp
 * debug1: [ COPY ] /tmp/example.jp/.ssh/Makefile
 * debug1: [ COPY ] /tmp/example.jp/lib/Makefile
 * debug1: [ COPY ] /tmp/example.jp/script/Makefile
 * debug1: [ COPY ] /tmp/example.jp/server/Makefile
 * debug1: [ COPY ] /tmp/example.jp/server/roles/Makefile
 * debug1: [ COPY ] /tmp/example.jp/server/spec/Makefile
 * debug1: [ COPY ] /tmp/example.jp/Makefile
 * debug1: [ COPY ] /tmp/example.jp/Vagrant.mk
 * debug1: [ COPY ] /tmp/example.jp/Ansible.mk
 * debug1: [ COPY ] /tmp/example.jp/Serverspec.mk
 * debug1: [ COPY ] /tmp/example.jp/Rakefile
 * debug1: [ COPY ] /tmp/example.jp/.rspec
 * debug1: [ COPY ] /tmp/example.jp/.make-server-directory
 * debug1: [ COPY ] /tmp/example.jp/.default-inventoryfile
 * debug1: [ COPY ] /tmp/example.jp/.default-playbook-file
```

ここでは`example.jp`配下のWebサーバ2台とメールサーバ1台を構築・構成管理すること
にします。`makeserverctl --setup`コマンドは現在のディレクトリに必要なディレクトリ
構造を作り、そして`makeserverctl --rootdir`コマンドの実行結果で示されるディレクトリ
から複数のMakefileを`exampel.jp/`ディレクトリにコピーします。

### make server
`server` target of ./Makefile create the following directories and copy files
to the directory.

| Directory     | Files in the directory                                      |
|---------------|-------------------------------------------------------------|
| .ssh/         | SSH key pair for `deploy` user                              |
| lib/          | Helper script for Serverspec and Rakefile                   |
| server/       | Playbooks, inventory files, and a config file for Ansible   |
| server/roles/ | Bootstrap and cleandown role for Ansible                    |
| server/spec/  | Test codes for Serverspec                                   |

```shell
$ make server
cd .ssh && /bin/make DEPLOYKEY=./.ssh/ssh.deploy-rsa.key DEPLOYUSER=deploy
ssh-keygen -vf ssh.deploy-rsa.key -N '' -C "deploy@example.jp"
Generating public/private rsa key pair.
Your identification has been saved in ssh.deploy-rsa.key.
...
```

Makefileの`server`ターゲットを実行すると、以下のようなディレクトリが作られ、
各ファイルがそれらのディレクトリにコピーされます。

| ディレクトリ  | 各ディレクトリに作られるファイル                            |
|---------------|-------------------------------------------------------------|
| .ssh/         | `deploy`ユーザ用のSSH鍵ペア                                 |
| lib/          | ServerspecとRakefile用補助スクリプト(Ruby)                  |
| server/       | Ansible用設定ファイル、Playbookとインベントリファイル       |
| server/roles/ | Ansible用bootstrapとcleandownロール                         |
| server/spec/  | Serverspec用テストコード                                    |

## Use Vagrant ? | Vagrantを使う場合
### Targets for Making a Virtual Machine | 仮想マシンを作るターゲット
If you want to use Vagrant as a machine for testing your playbooks and test codes,
the following commands may be useful. `make <box-name>-box` command creates a 
virtual box machine and the inventory file: `server/vagrant` for Ansible.

```shell
% make list
vagrant box list
centos56-i386    (virtualbox, 0)
centos64-x86_64  (virtualbox, 0)
centos65-x86_64  (virtualbox, 0)
centos70-x86_64  (virtualbox, 0)
debian70-x84_64  (virtualbox, 0)
debian73-x86_64  (virtualbox, 0)
freebsd101-amd64 (virtualbox, 0)
freebsd82-i386   (virtualbox, 0)
freebsd92-amd64  (virtualbox, 0)
freebsd92-i386   (virtualbox, 0)
openbsd53-x86_64 (virtualbox, 0)

% make freebsd92-amd64-box
/usr/bin/make -f Vagrant.mk freebsd92-amd64-box
/usr/bin/make .directory-location
makeserverctl --location
! test -f ./Vagrantfile
vagrant init freebsd92-amd64
...
VMIPV4ADDRESS="`/usr/bin/make addr`"; \
	cat /usr/local/src/make-server/server/vagrant | sed \
		-e "s/__IPV4ADDRESS__/$VMIPV4ADDRESS/g" \
		-e 's/__OPENSSHPORT__/22/g' \
	> server/vagrant
...
```

もしもPlaybookやServerspecのテストコードの試験用にVagrantを使う場合は下記の
コマンド実行例が役に立つかもしれません。`make <ボックス名>-box`コマンドは
インストール済のVagrant boxから仮想マシンを作り、Ansibleのインベントリファイル
として`server/vagrant`を生成します。

### Other Targets for Vagrant | その他のVagrant用ターゲット
Some useful targets for Vagrant are defined in `./Vagrant.mk` file such as
`up`: executes `vagrant up`, `addr:` Print the IPv4 address of the virtual machine,
`down:` executes `vagrant halt`. And you can login to the virtual machine using
ssh by `make` command.

```shell
% make up
vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'freebsd92-amd64'...
...
==> default: Running provisioner: shell...
    default: Running: inline script

% make addr
172.25.221.81

% make
ssh -v42 -l vagrant -i .vagrant/machines/default/virtualbox/private_key `/usr/bin/make addr`
OpenSSH_6.2p2, OSSLShim 0.9.8r 8 Dec 2011
...
FreeBSD 9.2-RELEASE-p3 (GENERIC) #0: Sat Jan 11 03:25:02 UTC 2014
[vagrant@vm ~]$ ^D

% make down
vagrant halt
==> default: Attempting graceful shutdown of VM...
```

`./Vagrant.mk`には幾つかのVagrant用ターゲットが定義されています。
`up:`は`vagrant up`を実行、`addr:`は作った仮想マシンのIPv4アドレスを表示、
`down:`は`vagrant halt`を実行します。そして`make`だけを実行すると作成した仮想
マシンにSSHでログインする事が出来ます。

## List of files in make-server
The following table shows the list of files and directories of make-server.
Files that its name ends with '*' sign are updated by `makeserverctl --update-makefile`
command.

| Filename                |   Description                                     |
|-------------------------|---------------------------------------------------|
| README.md               | This file                                         |
| Makefile*               | Makefile for make-server                          |
| Ansible.mk*             | Makefile for Ansible                              |
| Serverspec.mk*          | Makefile for Serverspec tests                     |
| Vagrant.mk*             | Makefile for Vagrant virtual machine              |
| Rakefile*               | Rakefile for Serverspec tests                     |
| NodeLocal.mk            | User defined Makefile(not updated automatically)  |
| Vagrantfile             | Configuration file for Vagrant                    |
| ansible.cfg             | Symbolic link to server/ansible-config            |
| .default-inventoryfile  | Defines default inventory file name               |
| .default-playbook-file  | Defines default playbook file name                |
| .make-server-directory* | Defines the path to cloned make-server            |
| .ssh/                   | SSH directory for user "deploy"                   |
| data/                   | Mount point for Vagrant virtual machine           |
| lib/                    | Helper scripts for Serverspec tests               |
| script/                 | Scripts for Vagrant shell provisioning            |
| server/                 | Files for Ansible and Serverspec                  |
|   install               | Inventory file for initializing host as root      |
|   develop               | Inventory file for development                    |
|   staging               | Inventory file for staging servers                |
|   product               | Inventory file for production servers             |
|   sandbox               | Inventory file for sandbox servers                |
|   vagrant               | Inventory file for Vagrant virtual machine        |
|   build-machines.yml    | Default playbook(not updated automatically)       |
|   10-build-stage.yml    | Playbook for installing Python 2.7 and sudo       |
|   11-selinux-off.yml    | Playbook to disable SELinux                       |
|   20-deploy-user.yml    | Playbook for creating user "deploy"               |
|   21-enable-epel.yml    | Playbook to enable EPEL repository(Linux only)    |
|   30-update-sshd.yml    | Playbook for changing sshd port                   |
|   41-vagrant-uid.yml    | Playbook for changing uid of "vagrant" user       |
|   49-make-sslkey.yml    | Playbook for generating secret key,CSR,and CRT    |
|   50-make-server.yml    | Sample playbook for making servers                |
|   ansible-config        | Ansible configuration file for this node          |
|   log                   | Log file specified in ./ansible-config file       |
|   roles/                | Ansible roles                                     |
|   spec/                 | Test codes for ./*.yml playbooks                  |

上記の表はmake-serverのファイルとディレクトリ一覧です。'*'印が付いているファイル
は`makeserverctl --update-makefile`コマンドで更新されます。

## Ansible Roles | ロール

### The List of Roles | ロールの一覧
`make role-index` shows the list of available roles and roles created in the 
current node directory like followings:

```shell
% make role-index
*****************************************************************************
 `make <role-name>-role` command copy or create specified role directories in
 ./server/roles. Available roles are below:
*****************************************************************************
- bootstrap ....................... Installed
- cleandown ....................... Installed
- rpm/apache ...................... Only in /tmp/example.jp/server/roles
- env/selinux ..................... Available to be installed using `make <role-name>-role`
- rpm/munin-cron .................. Available to be installed using `make <role-name>-role`
- rpm/munin-node .................. Available to be installed using `make <role-name>-role`
- rpm/ruby ........................ Available to be installed using `make <role-name>-role`
- rpm/svnserve .................... Available to be installed using `make <role-name>-role`
- src/apache-2.2 .................. Available to be installed using `make <role-name>-role`
- src/bind-9 ...................... Available to be installed using `make <role-name>-role`
- src/cpanm ....................... Available to be installed using `make <role-name>-role`
- src/dovecot ..................... Available to be installed using `make <role-name>-role`
- src/firewall .................... Available to be installed using `make <role-name>-role`
- src/mysql-5.5 ................... Available to be installed using `make <role-name>-role`
- src/netqmail .................... Available to be installed using `make <role-name>-role`
- src/nginx ....................... Available to be installed using `make <role-name>-role`
- src/opensmtpd ................... Available to be installed using `make <role-name>-role`
- src/openssl ..................... Available to be installed using `make <role-name>-role`
- src/perl ........................ Available to be installed using `make <role-name>-role`
- src/php-5.3 ..................... Available to be installed using `make <role-name>-role`
- src/php-5.5 ..................... Available to be installed using `make <role-name>-role`
- src/phpmyadmin .................. Available to be installed using `make <role-name>-role`
- src/postgresql .................. Available to be installed using `make <role-name>-role`
- src/sendmail-local .............. Available to be installed using `make <role-name>-role`
- src/sendmail-system ............. Available to be installed using `make <role-name>-role`
- src/vsftpd ...................... Available to be installed using `make <role-name>-role`
```

`make role-index`コマンドを実行すると、上記のようにインストール可能なロールと
現在のノードディレクトリに作成されたロールが表示されます。

### Import Roles | ロールの取り込み
`make <role-name>-role` command help you to import existing role fles from the
root directory which is cloned from GitHub to the current node directory
as a template. For example, to execute `make src/postgresql-role` command copy
files for the role into the current directory like following:

```shell
cd server && /usr/bin/make src/postgresql-role
cd roles && /usr/bin/make src/postgresql-role
/usr/bin/make src/postgresql-role-to-be-created
...
/bin/cp -vRp -i /usr/local/src/make-server/server/roles/src/postgresql ./`dirname src/postgresql`/
/usr/local/src/make-server/server/roles/src/postgresql -> ./src/postgresql
/usr/local/src/make-server/server/roles/src/postgresql/defaults -> ./src/postgresql/defaults
/usr/local/src/make-server/server/roles/src/postgresql/files -> ./src/postgresql/files
/usr/local/src/make-server/server/roles/src/postgresql/handlers -> ./src/postgresql/handlers
/usr/local/src/make-server/server/roles/src/postgresql/handlers/main.yml -> ./src/postgresql/handlers/main.yml
/usr/local/src/make-server/server/roles/src/postgresql/meta -> ./src/postgresql/meta
/usr/local/src/make-server/server/roles/src/postgresql/tasks -> ./src/postgresql/tasks
/usr/local/src/make-server/server/roles/src/postgresql/tasks/boot-script.yml -> ./src/postgresql/tasks/boot-script.yml
/usr/local/src/make-server/server/roles/src/postgresql/tasks/compile-src.yml -> ./src/postgresql/tasks/compile-src.yml
...
/usr/local/src/make-server/server/roles/src/postgresql/vars -> ./src/postgresql/vars
/usr/local/src/make-server/server/roles/src/postgresql/vars/main.yml -> ./src/postgresql/vars/main.yml

% make role-index
...
- bootstrap ....................... Installed
- cleandown ....................... Installed
- rpm/apache ...................... Only in /tmp/example.jp/server/roles
- src/postgresql .................. Installed
- env/selinux ..................... Available to be installed using `make <role-name>-role`
...
```

`make <role-name>-role` commandを使うと`git clone`したディレクトリから現在の
ノードディレクトリへ、make-serverに同梱されているロールのファイルをテンプレート
として取り込むのに便利です。例えば、`make src/postgresql-role`を実行すると上記
のように`server/roles/src/postgresql`ディレクトリにファイルが取り込まれます。

------- I've wrote README.md until here ---------

### Create Roles | ロールの作成

## Inventory Files | インベントリファイル

## Execute Ansible Playbooks | Playbookの実行

## Execute Serverspec Tests | Serverspecテストの実行

## .default-* Files | .default-*ファイル

```
$ vi ansible/product
[product]
    www[01:25].example.jp
    mail.example.jp

    [webservers]
    www[01:25].example.jp

    [mailservers]
    mail.example.jp

## Prepare Vagrant vm as a sandbox

"make list" command shows the list of available vagrant boxes.

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
    mkdir -p ./server
    make common-role
    ...
    $ make up
    ==> default: Importing base box 'centos64-x86_64'...
    Progress: 50%
    ...

## Copy roles

    $ cd ~/var/rhosts/example.jp
    $ make src/nginx-role src/sendmail-system-role src/mysql-5.5-role
    ...

When `make apache-role` executed, roles/apache will be copied from
make-server/ansible/roles directory to current `ansible/` directory if 
roles/apache exists in this repository. 

However, when make-server/ansible/roles/apache does not exist, only directory
tree will be created in ./ansible/roles directory followed Best Practices.

`make apache-role`を実行すると、このリポジトリにansible/roles/apacheがある場合は
それがコピーされ、無ければBest Practicesに従ったディレクトリ構造だけを作ります。

REPOSITORY
----------
https://github.com/azumakuniyuki/make-server

AUTHOR
------
azumakuniyuki

