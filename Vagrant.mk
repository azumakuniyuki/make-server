# Makefile for make-server/Vagrant
# __     __                          _               _    
# \ \   / /_ _  __ _ _ __ __ _ _ __ | |_   _ __ ___ | | __
#  \ \ / / _` |/ _` | '__/ _` | '_ \| __| | '_ ` _ \| |/ /
#   \ V / (_| | (_| | | | (_| | | | | |_ _| | | | | |   < 
#    \_/ \__,_|\__, |_|  \__,_|_| |_|\__(_)_| |_| |_|_|\_\
#              |___/                                      
# ---------------------------------------------------------------------------
HEREIAM := $(shell pwd)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)
CURNODE := $(shell echo $(dir $(HEREIAM)) | xargs basename )
MAKEDIR := mkdir -p

.DEFAULT_GOAL := login
MAKESERVERCTL := makeserverctl
MAKESERVERDIR := $(shell head -1 .make-server-directory)
ROOTDIRECTORY := server
VAGRANTCONFIG := Vagrantfile
VAGRANTSCRIPT := script
VAG_INVENTORY := $(ROOTDIRECTORY)/vagrant
MOUNTPOINTDIR := data
VIRTUALBOXDIR := .vagrant
VIRTUALBOXNET := 172.25
SSHCOMMAND    := ssh -v42
SECRETKEY     := $(VIRTUALBOXDIR)/machines/default/virtualbox/private_key

# ---------------------------------------------------------------------------
.PHONY: clean all
.directory-location:
	@$(MAKESERVERCTL) --location

%-box:
	$(MAKE) .directory-location
	- ! test -f ./$(VAGRANTCONFIG)
	vagrant init $*
	rm -f ./$(VAGRANTCONFIG)
	$(MAKE) -f Vagrant.mk $(VAGRANTCONFIG) VIRTUALBOXSET=$*
	$(MAKE) -f Vagrant.mk $(VAG_INVENTORY)
	$(MAKE) -f Vagrant.mk $(VAGRANTSCRIPT)
	$(MAKEDIR) $(MOUNTPOINTDIR)

$(VAG_INVENTORY):
	test -f $(VAGRANTCONFIG)
	VMIPV4ADDRESS="`$(MAKE) addr`"; \
	cat $(MAKESERVERDIR)/$@ | sed \
		-e "s/__IPV4ADDRESS__/$$VMIPV4ADDRESS/g" \
		-e 's/__OPENSSHPORT__/22/g' \
	> $@

$(VAGRANTCONFIG):
	O3="`perl -lE 'print int(rand(250)) + 2'`"; \
	O4="`perl -lE 'print int(rand(250)) + 2'`"; \
	cat $(MAKESERVERDIR)/$@ | sed \
		-e 's/__HOSTNAME__/vm.$(CURNODE)/g' \
		-e "s/__IPV4ADDRESS__/$(VIRTUALBOXNET).$$O3.$$O4/g" \
		-e 's/__VIRTUALBOX__/$(VIRTUALBOXSET)/g' > ./$@

$(VAGRANTSCRIPT): .directory-location
	$(MAKE) -C $@

addr:
	@test -f $(VAGRANTCONFIG)
	@grep 'private_network' ./$(VAGRANTCONFIG) | sed -e 's/^.*ip://g' | tr -d ' "'

down: $(VAGRANTCONFIG) $(VIRTUALBOXDIR)
	vagrant halt

list:
	vagrant box list

login:
	$(SSHCOMMAND) -l vagrant -i $(SECRETKEY) `$(MAKE) addr`

os:
	@test -f $(VAGRANTCONFIG)
	@grep 'config.vm.box = ' $(VAGRANTCONFIG) | awk '{ print $$3 }' | tr -d '"'

restart: $(VAGRANTCONFIG) $(VIRTUALBOXDIR)
	vagrant reload

ssh:
	$(SSHCOMMAND) -l $(DEPLOYUSER) -i $(DEPLOYKEY) `$(MAKE) addr`

up: $(VAGRANTSCRIPT) $(VAGRANTCONFIG)
	$(MAKE) -f Vagrant.mk $(VAG_INVENTORY)
	$(MAKE) -f Makefile remove-host-key
	vagrant up

destroy: $(VAGRANTCONFIG)
	vagrant destroy
	$(MAKE) -f Makefile remove-host-key

init-vm: $(VAGRANTCONFIG)
	$(MAKE) destroy && $(MAKE) up
	$(MAKE) init-host INVENTORYFILE=$(ROOTDIRECTORY)/vagrant

clean:

clean-vm:
	rm -f  ./$(VAGRANTCONFIG) ./$(VAG_INVENTORY)
	rm -rf ./$(VIRTUALBOXDIR)

