# Makefile for ansible
#  __  __       _         __ _ _      
# |  \/  | __ _| | _____ / _(_) | ___ 
# | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | |  | | (_| |   <  __/  _| | |  __/
# |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
HEREIAM    = $(shell pwd)
ANSIBLE    = $(shell which ansible)
PWDNAME    = $(shell echo $(HEREIAM) | xargs basename)
EXAMPLE    = ~/var/rhosts/make-server
SUBDIRS	   = ansible

ANSIBLEDIR = ansible
ANSIBLELOG = ./$(ANSIBLEDIR)/log
ANSIBLECFG = ./$(ANSIBLEDIR)/config
INVENTORY  = ./$(ANSIBLEDIR)/hosts
INVENTORIES= sandbox install develop staging product
PLAYBOOKS  = 10-build-stage.yml 20-deploy-user.yml 21-enable-epel.yml \
			 30-update-sshd.yml 49-make-sslkey.yml 50-make-server.yml
SERVERSPEC = ./spec
VAGRANTNET = 172.25
VAGRANTSSH = .vagrant/machines/default/virtualbox/private_key
VAGRANTFILE= Vagrantfile
DEPLOYKEY  = ./.ssh/id2-deploy-rsa

.PHONY: clean
login:
	ssh -l vagrant -i $(VAGRANTSSH) `make addr`

ssh:
	make key
	ssh -l deploy -i $(DEPLOYKEY) `make addr`

key:
	test -d ./.ssh || mkdir ./.ssh
	test -f $(DEPLOYKEY) || ssh-keygen -vf $(DEPLOYKEY) -N '' -C "deploy@`basename $(PWDNAME)`"

os:
	@test -f ./$(VAGRANTFILE) && grep 'config.vm.box = ' $(VAGRANTFILE) \
		| awk '{ print $$3 }' | tr -d '"'

here:
	@echo $(PWDNAME)

update:
	if [ "`basename $(HEREIAM)`" != "`basename $(EXAMPLE)`" ]; then \
		echo 'Update Makefile' ;\
		cp $(EXAMPLE)/Makefile ./ ;\
		for V in $(PLAYBOOKS); do \
			test -f ./$(ANSIBLEDIR)/$$V || cp $(EXAMPLE)/ansible/$$V ./$(ANSIBLEDIR) ;\
		done ;\
	fi

# Ansible related targets
ping:
	$(ANSIBLE) all -i $(INVENTORY) -m ping

vars:
	$(ANSIBLE) all -i $(INVENTORY) -m setup

node:
	$(ANSIBLE) all -i $(INVENTORY) -m raw -a 'hostname'

ansible:
	mkdir -p ./$(ANSIBLEDIR)
	mkdir ./tmp
	make common-role
	if [ "`basename $(HEREIAM)`" = "`basename $(EXAMPLE)`" ]; then \
		for V in hosts $(INVENTORIES); do \
			test -f ./$(ANSIBLEDIR)/$$V || touch ./$(ANSIBLEDIR)/$$V ;\
		done ;\
	else \
		for V in $(INVENTORIES) $(PLAYBOOKS); do \
			test -f ./$(ANSIBLEDIR)/$$V || cp -vp $(EXAMPLE)/$(ANSIBLEDIR)/$$V ./$(ANSIBLEDIR)/ ;\
		done ;\
		if [ -f "./$(VAGRANTFILE)" ]; then \
			X="`make addr`" ;\
			cat $(EXAMPLE)/$(ANSIBLEDIR)/sandbox | sed \
				-e "s/__IPV4ADDRESS__/$$X/g" \
				-e 's/__SSHPORT__/22/g' \
			> ./$(ANSIBLEDIR)/sandbox ;\
		else \
			cat $(EXAMPLE)/$(ANSIBLEDIR)/sandbox | sed \
				-e 's/__IPV4ADDRESS__/127.0.0.1/g' \
				-e "s/__SSHPORT__/2222/g" \
			> ./$(ANSIBLEDIR)/sandbox ;\
		fi ;\
	fi
	cp ./$(ANSIBLEDIR)/sandbox ./$(INVENTORY)
	if [ ! -f "$(ANSIBLECFG)" ]; then \
		cp $(EXAMPLE)/ansible/config $(ANSIBLECFG) ;\
		ln -fs $(ANSIBLECFG) ./ansible.cfg ;\
	fi

%-role: ansible
	if [ ! -d $(EXAMPLE)/$(ANSIBLEDIR)/roles/`echo $* | tr '-' '/'` -o "`basename $(HEREIAM)`" = "`basename $(EXAMPLE)`" ]; then \
		for V in files handlers tasks templates vars defaults meta; do \
			mkdir -p ./$(ANSIBLEDIR)/roles/`echo $* | tr '-' '/'`/$$V ;\
		done ;\
	else \
		mkdir -p ./$(ANSIBLEDIR)/roles ;\
		if [ ! -d "./$(ANSIBLEDIR)/roles/`echo $* | tr '-' '/'`" ]; then \
			mkdir -p ./$(ANSIBLEDIR)/roles/`echo $* | tr '-' '/'`/ ;\
			cp -Rvp $(EXAMPLE)/$(ANSIBLEDIR)/roles/`echo $* | tr '-' '/'`/* ./$(ANSIBLEDIR)/roles/`echo $* | tr '-' '/'`/ ;\
			echo ;\
		else \
			cp -Rip $(EXAMPLE)/$(ANSIBLEDIR)/roles/`echo $* | tr '-' '/'`/* ./$(ANSIBLEDIR)/roles/`echo $* | tr '-' '/'`/ ;\
			echo ;\
		fi ;\
	fi

role-index:
	@find $(EXAMPLE)/ansible/roles -type f -name 'main.yml' \
		| grep '/tasks/main.yml' \
		| sed \
			-e 's|/tasks/main.yml||g' \
			-e 's|^.*/ansible/roles/||g' 

# serverspec related targets
serverspec:
	serverspec-init

test:
	rake spec

# Vagrant related targets
vagrant:
	test -f ./$(VAGRANTFILE)

%-box:
	if [ ! -f "./$(VAGRANTFILE)" ]; then \
		vagrant init $* ;\
		X="`perl -lE 'print int(rand(250)) + 2'`" ;\
		Y="`perl -lE 'print int(rand(250)) + 2'`" ;\
		cat $(EXAMPLE)/$(VAGRANTFILE) | sed \
			-e 's/__HOSTNAME__/vm.$(PWDNAME)/g' \
			-e "s/__IPV4ADDRESS__/$(VAGRANTNET).$$X.$$Y/g" \
			-e 's/__VIRTUALBOX__/$*/g' > ./$(VAGRANTFILE) ;\
	fi
	mkdir -p ./data

addr:
	@if [ -f "./$(VAGRANTFILE)" ]; then \
		grep 'private_network' ./$(VAGRANTFILE) | sed -e 's/^.*ip://g' | tr -d ' "' ;\
	fi

list:
	vagrant box list

up: vagrant
	ssh-keygen -R `make addr`
	vagrant up

destroy: vagrant
	vagrant destroy
	ssh-keygen -R `make addr`

init-vm: vagrant
	make destroy && make up

help:
	vagrant --help

down: vagrant
	vagrant halt

restart: vagrant
	vagrant reload

push:
	for G in `grep -E '^[[]remote' .git/config | cut -d' ' -f2 | tr -d '"]'`; do \
		git push --tags $$G master; \
	done

clean:
	for V in `/bin/ls -1 ~/*.retry 2> /dev/null`; do rm -f $$V; done

