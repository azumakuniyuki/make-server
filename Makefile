# Makefile for github.com/azumakuniyuki/make-server
#  __  __       _         __ _ _      
# |  \/  | __ _| | _____ / _(_) | ___ 
# | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | |  | | (_| |   <  __/  _| | |  __/
# |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
VERSION := '3.0.0'
HEREIAM := $(shell pwd)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)
MAKEDIR := mkdir -p
ROOTDIR := server
SUBDIRS := server lib bin .ssh script
SPECDIR := $(ROOTDIR)/spec
UBINDIR := bin
ULIBDIR := lib

.DEFAULT_GOAL := login
MAKESERVERCTL := makeserverctl
MAKESERVERDIR  = $(shell head -1 .make-server-directory)

DEPLOYKEY   = ./.ssh/ssh.deploy-rsa.key
DEPLOYUSER := deploy
AS_TARGETS := ping vars node init-host
VG_TARGETS := addr destroy down init-vm list login os restart ssh up

# -----------------------------------------------------------------------------
.PHONY: clean all $(SUBDIRS)
.make-server-directory:
	echo $(HEREIAM) > ./$@

.directory-location:
	$(MAKESERVERCTL) --location

ansible.cfg:
	cd $(ROOTDIR) && make ansible-config
	test -L ./$(ROOTDIR)/ansible-cfg || ln -s $(ROOTDIR)/ansible-config ./$@

env:
	$(MAKE) install-ansible
	$(MAKE) install-serverspec

setup:
	$(MAKE) .directory-location
	$(MAKE) server

version:
	@echo make-server $(VERSION)

# -----------------------------------------------------------------------------
# Sub directory: .ssh/
key-pair:
	cd .ssh && $(MAKE) DEPLOYKEY=$(DEPLOYKEY) DEPLOYUSER=$(DEPLOYUSER)

remove-host-key:
	test -f ./Vagrantfile
	ssh-keygen -R `$(MAKE) addr`

# -----------------------------------------------------------------------------
# Sub directory: bin/
command install uninstall:
	$(MAKE) .make-server-directory
	test -d $(UBINDIR) && cd $(UBINDIR)/ && $(MAKE) $@

# -----------------------------------------------------------------------------
# Sub directory: lib/
lib:
	$(MAKE) -C $@

# -----------------------------------------------------------------------------
# Sub directory: tmp/
tmp:
	$(MAKEDIR) $@

# -----------------------------------------------------------------------------
# Sub directory: server/
server: key-pair tmp lib
	$(MAKE) -C $@
	$(MAKE) ansible.cfg
	@echo
	@$(MAKE) role-index

# -----------------------------------------------------------------------------
# Ansible related targets
$(AS_TARGETS):
	$(MAKE) -f Ansible.mk $@

%-role:
	cd $(ROOTDIR) && $(MAKE) $@

build:
	$(MAKE) -f Ansible.mk $@

install-ansible:
	$(MAKE) -f Ansible.mk install

role-index:
	@cd $(ROOTDIR) && $(MAKE) $@

# -----------------------------------------------------------------------------
# serverspec related targets
test:
	$(MAKE) -f Serverspec.mk test

install-serverspec:
	$(MAKE) -f Serverspec.mk install

# -----------------------------------------------------------------------------
# Vagrant related targets
$(VG_TARGETS):
	@$(MAKE) -f Vagrant.mk $@

%-box:
	$(MAKE) -f Vagrant.mk $@

# -----------------------------------------------------------------------------
# Targets for make-server authors
push:
	for G in `git remote show -n`; do git push --tags $$G master; done

clean:
	$(MAKE) -f Ansible.mk $@
	$(MAKE) -f Serverspec.mk $@
	$(MAKE) -f Vagrant.mk $@
	cd $(UBINDIR) && make $@
	cd $(ROOTDIR) && make $@

