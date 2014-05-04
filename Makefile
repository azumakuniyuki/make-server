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

ANSIBLEDIR = ansible
ANSIBLELOG = ./$(ANSIBLEDIR)/log
ANSIBLECFG = ./$(ANSIBLEDIR)/config
INVENTORY  = ./$(ANSIBLEDIR)/hosts
SERVERSPEC = ./spec
VAGRANTNET = 172.25
VAGRANTSSH = ~/.ssh/vagrant-ssh-key
VAGRANTFILE= Vagrantfile

.PHONY: clean
here:
	@echo $(PWDNAME)

update:
	@echo 'Update Makefile'
	cp $(EXAMPLE)/Makefile ./

# Ansible related targets
ping:
	$(ANSIBLE) all -i $(INVENTORY) -m ping

vars:
	$(ANSIBLE) all -i $(INVENTORY) -m setup

node:
	$(ANSIBLE) all -i $(INVENTORY) -m raw -a 'hostname'

ansible:
	mkdir -p ./$(ANSIBLEDIR)
	make common-role
	if [ "`basename $(HEREIAM)`" = "`basename $(EXAMPLE)`" ]; then \
		for V in hosts develop staging product; do \
			test -f ./$(ANSIBLEDIR)/$$V || touch ./$(ANSIBLEDIR)/$$V ;\
		done ;\
	else \
		for V in develop staging product; do \
			test -f ./$(ANSIBLEDIR)/$$V || cp -vp $(EXAMPLE)/$(ANSIBLEDIR)/$$V ./$(ANSIBLEDIR)/ ;\
		done ;\
		if [ ! -f "./$(ANSIBLEDIR)/hosts" ]; then \
			if [ -f "./$(VAGRANTFILE)" ]; then \
				X="`make addr`" ;\
				cat $(EXAMPLE)/$(ANSIBLEDIR)/hosts | sed \
					-e "s/__IPV4ADDRESS__/$$X/g" \
					-e 's/__SSHPORT__/22/g' \
				> ./$(ANSIBLEDIR)/hosts ;\
			else \
				cat $(EXAMPLE)/$(ANSIBLEDIR)/hosts | sed \
					-e 's/__IPV4ADDRESS__/127.0.0.1/g' \
					-e "s/__SSHPORT__/2222/g" \
				> ./$(ANSIBLEDIR)/hosts ;\
			fi ;\
		fi ;\
	fi
	if [ ! -f "$(ANSIBLECFG)" ]; then \
		cp $(EXAMPLE)/ansible/config $(ANSIBLECFG) ;\
		ln -fs $(ANSIBLECFG) ./ansible.cfg ;\
	fi

%-role:
	if [ ! -d $(EXAMPLE)/$(ANSIBLEDIR)/roles/$* -o "`basename $(HEREIAM)`" = "`basename $(EXAMPLE)`" ]; then \
		for V in files handlers tasks templates vars defaults meta; do \
			mkdir -p ./$(ANSIBLEDIR)/roles/$*/$$V ;\
			touch /tmp/neko ;\
		done ;\
	else \
		mkdir -p ./$(ANSIBLEDIR)/roles ;\
		if [ ! -d "./$(ANSIBLEDIR)/roles/$*" ]; then \
			cp -Rvp $(EXAMPLE)/$(ANSIBLEDIR)/roles/$* ./$(ANSIBLEDIR)/roles/ ;\
			if [ -f "$(EXAMPLE)/$(ANSIBLEDIR)/$*.yml" ]; then \
				cp -vp  $(EXAMPLE)/$(ANSIBLEDIR)/$*.yml ./$(ANSIBLEDIR)/ || true;\
			fi ;\
		else \
			cp -Rip $(EXAMPLE)/$(ANSIBLEDIR)/roles/$* ./$(ANSIBLEDIR)/roles/ ;\
			if [ -f "$(EXAMPLE)/$(ANSIBLEDIR)/$*.yml" ]; then \
				cp -ivp $(EXAMPLE)/$(ANSIBLEDIR)/$*.yml ./$(ANSIBLEDIR)/ || true ;\
			fi ;\
		fi ;\
	fi

# serverspec related targets
serverspec:
	serverspec-init

test:
	rake spec

# Vagrant related targets
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

ssh:
	vagrant ssh

list:
	vagrant box list

init-vm:
	vagrant destroy && vagrant up

help:
	vagrant --help

down: 
	make halt

restart: 
	make reload

%:
	vagrant $@

