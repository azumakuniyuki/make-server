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
The following commands are example for creating directory tree to build a web
server at `example.jp` domain.  `makeserverctl --setup` command create required
directory tree and copy some Makefiles from the directory which is the result of
`makeserverctl --rootdir` command to the `example.jp/` directory.

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

ここでは`example.jp`配下のWebサーバ1台を構築・構成管理することにします。
`makeserverctl --setup`コマンドは現在のディレクトリに必要なディレクトリ構造を
作り、そして`makeserverctl --rootdir`コマンドの実行結果で示されるディレクトリ
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

## Use Vagrant as a Sandbox | Vagrantを使う場合
### Targets for Making a VM | 仮想マシンを作るターゲット
If you want to use Vagrant as a machine for testing your playbooks and test codes,
the following commands may be useful. `make list`` command shows the list of 
available vagrant boxes, and `make <box-name>-box` command creates a virtual 
box machine and the inventory file: `server/vagrant` for Ansible.

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
コマンド実行例が役に立つかもしれません。`make list`コマンドは利用可能なVagrant
仮想マシンの一覧を表示し、`make <ボックス名>-box`コマンドはインストール済の
Vagrant boxから仮想マシンを作り、Ansibleのインベントリファイルとして
`server/vagrant`を生成します。

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

### Create Roles | ロールの作成
When you want to create a role which is not included in make-server, for example
installing Postfix from RPM, `make rpm/postfix-role` command makes a directory
tree following 
[Ansible Best Practices](http://docs.ansible.com/ansible/playbooks_best_practices.html) .

```shell
% make rpm/postfix-role
make rpm/postfix-role
cd server && /usr/bin/make rpm/postfix-role
cd roles && /usr/bin/make rpm/postfix-role
/usr/bin/make rpm/postfix-role-to-be-created
...

% find server/roles/rpm/postfix -type d
server/roles/rpm/postfix
server/roles/rpm/postfix/defaults
server/roles/rpm/postfix/files
server/roles/rpm/postfix/handlers
server/roles/rpm/postfix/meta
server/roles/rpm/postfix/spec
server/roles/rpm/postfix/tasks
server/roles/rpm/postfix/templates
server/roles/rpm/postfix/vars

% make role-index | grep postfix
- rpm/postfix ..................... Only in /tmp/example.jp/server/roles
```

make-serverに含まれていないロール、例えばRPMからPostfixをインストールするロール
`rpm/postfix`を作る場合、`make rpm/postfix-role`を実行すると
[Ansible Best Practices](http://docs.ansible.com/ansible/playbooks_best_practices.html)
に従ったディレクトリ構造を作ります。

## Inventory Files | インベントリファイル
Inventory files in `server/` directory of make-server are common between Ansible
and Serverspec. In other ways, Serverspec(`Rakefile` and helper scripts in `lib/`
directory) read Ansible's inventory files.

| Inventory Filename |   Description                                     |
|--------------------|---------------------------------------------------|
| install            | Inventory file for initializing host as root      |
| develop            | Inventory file for development                    |
| staging            | Inventory file for staging servers                |
| product            | Inventory file for production servers             |
| sandbox            | Inventory file for sandbox servers                |
| vagrant            | Inventory file for Vagrant virtual machine        |

make-serverの`server/`ディレクトリにあるインベントリファイルはAnsibleとServerspec
で共通になっています。言い換えると、Serverspec(`Rakefile`と`lib/`以下の補助スクリプト)
がAnsibleのインベントリファイルを読込むようになっています。

### server/install
`server/install` is an inventory file to build up Python and `sudo` program 
environment on the server you want to build for executing Ansible's playbook.

```ini
[install]
192.0.2.1

[install:vars]
ansible_ssh_port=22
ansible_ssh_user=root
ansible_ssh_pass=root-password
# ansible_ssh_private_key_file=/path/to/.ssh/ssh.root-seckey-rsa.key
ansible_python_interpreter=/usr/local/bin/python2.7
# ansible_connection=paramiko
```

`server/install`は構築したいサーバにPythonと`sudo`の環境を構築する為に使う事を
想定したPlaybookです。

After edit the inventory file, the following command builds Python and sudo 
environment and create `deploy` user on the  server.

```shell
% ansible-playbook -i server/install server/10-build-stage.yml server/20-deploy-user.yml
PLAY [all] ******************************************************************** 

GATHERING FACTS *************************************************************** 
ok: [vm]

TASK: [build-stage | Python 2.7 should have been installed(0)] **************** 
ok: [vm]
...
TASK: [deploy-user | Authorized key should be deployed] *********************** 
changed: [vm]

PLAY RECAP ******************************************************************** 
vm                         : ok=7    changed=6    unreachable=0    failed=0   
```

インベントリファイルを編集した後で上記のコマンドを実行するとPython環境の準備と
`sudo`の設定、そして`deploy`ユーザの作成が行われます。

### server/vagrant
`server/vagrant` is an inventory file for Vagrant vitual machine. The file is
automatically generated by `make <box-name>-box` command.

```ini
[vagrant]
vm ansible_ssh_host=172.25.221.81

[vagrant:vars]
ansible_ssh_port=22
ansible_ssh_user=vagrant
ansible_ssh_private_key_file=./.vagrant/machines/default/virtualbox/private_key
ansible_python_interpreter=/usr/bin/python
```

`server/vagrant`はVagrant仮想マシン専用のインベントリファイルで、`make <box-name>-box`
コマンドを実行すると自動的に生成されます。

## Execute Serverspec Tests | Serverspecテストの実行

### rake
`rake -T` command show the list of available targets for Serverspec test. These
targets are automatically generated by `lib/ansible_helper.rb` script when `rake`
command is executed.

```shell
% rake -T
rake spec:172.25.243.35:all          # Run all the serverspec tests to 172.25.243.35
rake spec:172.25.243.35:ansible-env  # Run tests for Ansible environment
rake spec:172.25.243.35:bootstrap    # Run serverspec tests to 172.25.243.35(bootstrap)
rake spec:172.25.243.35:src/nginx    # Run serverspec tests to 172.25.243.35(src/nginx)

% rake spec:172.25.243.35:ansible-env
/usr/local/bin/ruby -I/usr/local/lib/ruby/gems/2.2.0/gems/rspec-support-3.3.0/lib:/usr/local/lib/ruby/gems/2.2.0/gems/rspec-core-3.3.2/lib /usr/local/lib/ruby/gems/2.2.0/gems/rspec-core-3.3.2/exe/rspec --pattern ./server/spec/\[0-9\]\[0-9\]-\*.rb
* hostname = 172.25.243.35
* username = vagrant
* sshdport = 22
* identity = ./.vagrant/machines/default/virtualbox/private_key
...
  1) 30-update-sshd File "/etc/ssh/sshd_config" content 
     # Temporarily skipped with xdescribe
     # ./server/spec/30-update-sshd.rb:10


Finished in 0.3407 seconds (files took 1.28 seconds to load)
12 examples, 0 failures, 1 pending
```

`rake -T`コマンドを実行するとServerspecのテストで実行可能なターゲットの一覧が
表示されます。これらのターゲットは`rake`コマンドを実行したときに`lib/ansible_helper.rb`
スクリプトによって自動的に生成されます。

## .default-* Files | .default-*ファイル

`.default-inventoryfile` is called from `Makefile` and `Rakefile` to get default
inventory file name. `.default-playbook-file` is called from `Makefile` to get
default playbook file name to execute `ansible-playbook` command.

```shell
% cat .default-inventoryfile
vagrant

% cat .default-playbook-file
build-machines.yml

% make build
/usr/bin/make -f Ansible.mk build
makeserverctl --location
*** The following playbook will be executed by ansible-playbook command:
  - Playbook to be executed    : server/build-machines.yml
  - Inventory file to be loaded: server/vagrant
*** Are you sure you want to execute the playbook above? [Y/n]

% make test
/usr/bin/make -f Serverspec.mk test
rake INVENTORY=vagrant spec
/usr/local/bin/ruby -I/usr/local/lib/ruby/gems/2.2.0/gems/rspec-support-3.3.0/lib:/usr/local/lib/ruby/gems/2.2.0/gems/rspec-core-3.3.2/lib /usr/local/lib/ruby/gems/2.2.0/gems/rspec-core-3.3.2/exe/rspec --pattern ./server/spec/\[0-9\]\[0-9\]-\*.rb
* hostname = 172.25.243.35
* username = vagrant
* sshdport = 22
* identity = ./.vagrant/machines/default/virtualbox/private_key

10-build-stage
  Python environment
    Command "which python"
      stdout
        should match /\/bin\/python/
...
```

`.default-inventoryfile`は`Makefile`と`Rakefile`から既定のインベントリファイル名
を取得する為に呼び出され、`.default-playbook-file`は`ansible-playbook`コマンドで
実行するPlaybookのファイル名を取得する為に呼び出されます。

### "init-host" Target | "init-host"ターゲット

```shell
% make init-host
/usr/bin/make -f Ansible.mk init-host
makeserverctl --location
*** The following playbooks are executed by ansible-playbook command:
  - Playbooks to be executed:
    - server/10-build-stage.yml
    - server/11-selinux-off.yml
    - server/20-deploy-user.yml
  - Inventory file to be loaded:
    - server/vagrant
*** Are you sure you want to execute the playbooks above? [Y/n] y
*** make-server execute playbooks after  6 seconds ...
```

KNOWN BUGS | 既知のバグ
-----------------------
See [GitHub/azumakuniyuki/make-server/issues](https://github.com/azumakuniyuki/make-server/issues)

AUTHOR | 作者
-------------
[@azumakuniyuki](https://twitter.com/azumakuniyuki)

COPYRIGHT | 著作権
------------------
Copyright (C) 2014-2015 azumakuniyuki <github.com@azumakuniyuki.org>,
All Rights Reserved.

LICENSE | ライセンス
--------------------
This software is distributed under The BSD 2-Clause License.

