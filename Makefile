# Makefile for ansible and serverspec
#  __  __       _         __ _ _      
# |  \/  | __ _| | _____ / _(_) | ___ 
# | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | |  | | (_| |   <  __/  _| | |  __/
# |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
VERSION := '2.1.0'
HEREIAM := $(shell pwd)
ANSIBLE := $(shell which ansible)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)
ROOTDIR := server
SUBDIRS := server
MAKEDIR := mkdir -p

PROTOTYPE   := ~/var/rhosts/make-server
SCRIPTDIR   := bin
DEPLOYKEY    = ./.ssh/id2-deploy-rsa
DEPLOYUSER  := deploy
ANSIBLELOG  := $(ROOTDIR)/log
ANSIBLECFG  := $(ROOTDIR)/ansible-config
INVENTORY    = $(ROOTDIR)/vagrant
INVENTORIES := sandbox install develop staging product vagrant
PLAYBOOKS   := 10-build-stage.yml 11-selinux-off.yml \
			   20-deploy-user.yml 21-setup-repos.yml \
			   30-update-sshd.yml 49-make-sslkey.yml 50-make-server.yml
VAGRANTNET  := 172.25
VAGRANTKEY  := .vagrant/machines/default/virtualbox/private_key
VAGRANTCFG  := Vagrantfile

.PHONY: clean
login:
	ssh -l vagrant -i $(VAGRANTKEY) `$(MAKE) addr`

ssh:
	$(MAKE) key-pair
	ssh -l $(DEPLOYUSER) -i $(DEPLOYKEY) `$(MAKE) addr`

key-pair:
	test -d ./.ssh || $(MAKEDIR) ./.ssh
	test -f $(DEPLOYKEY) || ssh-keygen -vf $(DEPLOYKEY) -N '' -C "$(DEPLOYUSER)@`basename $(PWDNAME)`"

os:
	@test -f ./$(VAGRANTCFG) && grep 'config.vm.box = ' $(VAGRANTCFG) \
		| awk '{ print $$3 }' | tr -d '"'

here:
	@echo $(PWDNAME)

update-makefile:
	if [ "$(PWDNAME)" != "`basename $(PROTOTYPE)`" ]; then \
		cp $(PROTOTYPE)/Makefile ./ ;\
		if [ -d "./$(ROOTDIR)" ]; then \
			for V in $(PLAYBOOKS); do \
				test -f ./$(ROOTDIR)/$$V || cp $(PROTOTYPE)/$(ROOTDIR)/$$V ./$(ROOTDIR)/ ;\
			done ;\
		fi ;\
	fi

# Ansible related targets
ping:
	$(ANSIBLE) all -i $(INVENTORY) -m ping

vars:
	$(ANSIBLE) all -i $(INVENTORY) -m setup

node:
	$(ANSIBLE) all -i $(INVENTORY) -m raw -a 'hostname'

server:
	$(MAKEDIR) ./$(ROOTDIR)
	$(MAKEDIR) ./tmp
	$(MAKEDIR) ./$(SCRIPTDIR)
	cp -vRp $(PROTOTYPE)/$(SCRIPTDIR)/* ./$(SCRIPTDIR)/
	$(MAKE) common-role
	if [ "`basename $(HEREIAM)`" = "`basename $(PROTOTYPE)`" ]; then \
		for V in hosts $(INVENTORIES); do \
			test -f ./$(ROOTDIR)/$$V || touch ./$(ROOTDIR)/$$V ;\
		done ;\
	else \
		for V in $(INVENTORIES) $(PLAYBOOKS); do \
			test -f ./$(ROOTDIR)/$$V || cp -vp $(PROTOTYPE)/$(ROOTDIR)/$$V ./$(ROOTDIR)/ ;\
		done ;\
		$(MAKE) vm-inventory ;\
		for V in group_vars; do \
			test -d ./$(ROOTDIR)/$$V || ( \
				$(MAKEDIR) ./$(ROOTDIR)/$$V ;\
				cp -vRp $(PROTOTYPE)/$(ROOTDIR)/$$V/* $(ROOTDIR)/$$V/ ) ;\
		done ;\
	fi
	if [ ! -f "./$(ANSIBLECFG)" ]; then \
		cp $(PROTOTYPE)/$(ANSIBLECFG) ./$(ANSIBLECFG) ;\
		ln -fs ./$(ANSIBLECFG) ./ansible.cfg ;\
	fi

%-role: server
	if [ ! -d $(PROTOTYPE)/$(ROOTDIR)/roles/$* -o "`basename $(HEREIAM)`" = "`basename $(PROTOTYPE)`" ]; then \
		for V in files handlers tasks templates vars defaults meta; do \
			$(MAKEDIR) ./$(ROOTDIR)/roles/`echo $*`/$$V ;\
		done ;\
		for V in handlers tasks vars meta; do \
			if [ -n "`which figlet`" ]; then \
				p="./$(ROOTDIR)/roles/$*/$$V" ;\
				if [ ! -e "$$p/main.yml" -o ! -s "$$p/main.yml" ]; then \
					touch $$p/main.yml ;\
					figlet -w128 "`echo $* | cut -d '/' -f2`/$$V" | sed 's/^/# /g' >> $$p/main.yml ;\
				fi ;\
			fi ;\
		done ;\
		$(MAKEDIR) ./$(ROOTDIR)/roles/$*/spec ;\
	else \
		$(MAKEDIR) ./$(ROOTDIR)/roles ;\
		if [ ! -d "./$(ROOTDIR)/roles/$*" ]; then \
			$(MAKEDIR) ./$(ROOTDIR)/roles/$*/ ;\
			cp -Rvp $(PROTOTYPE)/$(ROOTDIR)/roles/$*/* ./$(ROOTDIR)/roles/$*/ ;\
			echo ;\
		else \
			cp -Rip $(PROTOTYPE)/$(ROOTDIR)/roles/$*/* ./$(ROOTDIR)/roles/$*/ ;\
			echo ;\
		fi ;\
	fi

role-index:
	@find $(PROTOTYPE)/$(ROOTDIR)/roles -type f -name 'main.yml' \
		| grep '/tasks/main.yml' \
		| sed \
			-e 's|/tasks/main.yml||g' \
			-e 's|^.*/$(ROOTDIR)/roles/||g' 

init-server: server key-pair
	ansible-playbook -i $(INVENTORY) \
		$(ROOTDIR)/10-build-stage.yml $(ROOTDIR)/11-selinux-off.yml $(ROOTDIR)/20-deploy-user.yml

# serverspec related targets
install-serverspec:
	sudo gem install serverspec

test:
	rake spec

# Vagrant related targets
vagrant:
	test -f ./$(VAGRANTCFG)

vm-inventory:
	if [ -f "./$(VAGRANTCFG)" ]; then \
		X="`$(MAKE) addr`" ;\
		cat $(PROTOTYPE)/$(INVENTORY) | sed \
			-e "s/__IPV4ADDRESS__/$$X/g" \
			-e 's/__OPENSSHPORT__/22/g' \
		> ./$(INVENTORY) ;\
	fi

%-box:
	if [ ! -f "./$(VAGRANTCFG)" ]; then \
		vagrant init $* ;\
		X="`perl -lE 'print int(rand(250)) + 2'`" ;\
		Y="`perl -lE 'print int(rand(250)) + 2'`" ;\
		cat $(PROTOTYPE)/$(VAGRANTCFG) | sed \
			-e 's/__HOSTNAME__/vm.$(PWDNAME)/g' \
			-e "s/__IPV4ADDRESS__/$(VAGRANTNET).$$X.$$Y/g" \
			-e 's/__VIRTUALBOX__/$*/g' > ./$(VAGRANTCFG) ;\
	fi
	$(MAKEDIR) ./data

addr:
	@if [ -f "./$(VAGRANTCFG)" ]; then \
		grep 'private_network' ./$(VAGRANTCFG) | sed -e 's/^.*ip://g' | tr -d ' "' ;\
	fi

list:
	vagrant box list

up: vagrant
	ssh-keygen -R `$(MAKE) addr`
	vagrant up

destroy: vagrant
	vagrant destroy
	ssh-keygen -R `$(MAKE) addr`

init-vm: vagrant
	$(MAKE) destroy && $(MAKE) up
	$(MAKE) init-server

help:
	vagrant --help

down: vagrant
	vagrant halt

restart: vagrant
	vagrant reload

# Targets for make-server authors
push:
	for G in `grep -E '^[[]remote' .git/config | cut -d' ' -f2 | tr -d '"]'`; do \
		git push --tags $$G master; \
	done

clean:
	for V in `/bin/ls -1 ~/*.retry 2> /dev/null`; do rm -f $$V; done

log-clean:
	cp /dev/null ./$(ANSIBLELOG)

