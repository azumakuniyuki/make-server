# Makefile for make-server/server
#                                ____  __       _         __ _ _      
#  ___  ___ _ ____   _____ _ __ / /  \/  | __ _| | _____ / _(_) | ___ 
# / __|/ _ \ '__\ \ / / _ \ '__/ /| |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# \__ \  __/ |   \ V /  __/ | / / | |  | | (_| |   <  __/  _| | |  __/
# |___/\___|_|    \_/ \___|_|/_/  |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
HEREIAM := $(shell pwd)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)
CURNODE := $(shell echo $(dir $(HEREIAM)) | xargs basename )
SUBDIRS := roles spec
SPECDIR := spec
ROLEDIR := roles
MAKEDIR := mkdir -p

.DEFAULT_GOAL := all
ROOTDIRECTORY := server
MAKESERVERCTL := makeserverctl
MAKESERVERDIR  = $(shell head -1 ../.make-server-directory)
INVENTORYFILE  = $(shell head -1 ../.default-inventoryfile)
DIRECTORYNAME  = $(notdir $(HEREIAM))
ANSIBLECONFIG := ansible-config
ANSIBLECMDLOG := log
INVENTORYLIST := develop install product sandbox staging
BUILDPLAYBOOK := build-machines.yml
PLAYBOOKFILES := 10-build-stage.yml 11-selinux-off.yml 20-deploy-user.yml \
				 21-setup-repos.yml 22-add-network.yml 30-update-sshd.yml \
				 41-vagrant-uid.yml 49-make-sslkey.yml 50-make-server.yml
ANSIBLETARGET := $(INVENTORYLIST) $(PLAYBOOKFILES)

# -----------------------------------------------------------------------------
.PHONY: clean all
.SUFFIXES:
.directory-location:
	@$(MAKESERVERCTL) --location

%-role:
	cd $(ROLEDIR) && $(MAKE) $@

all:
	$(MAKE) .directory-location
	$(MAKE) $(ANSIBLECONFIG) $(INVENTORYLIST) $(PLAYBOOKFILES) $(ANSIBLECMDLOG)
	$(MAKE) $(BUILDPLAYBOOK)
	$(MAKE) group_vars
	$(MAKE) $(SUBDIRS)
	cd $(ROLEDIR) && $(MAKE) bootstrap-role cleandown-role

$(ANSIBLECONFIG):
	cat $(MAKESERVERDIR)/$(DIRECTORYNAME)/$@ | sed \
		-e 's|@@ROOT_DIRECTORY@@|$(ROOTDIRECTORY)|g' \
		-e 's|@@DEFAULT_INVENTORYFILE@@|$(INVENTORYFILE)|g' > $@
	ln -s ./$(DIRECTORYNAME)/$@ ../ansible.cfg

$(ANSIBLECMDLOG):
	touch ./$@

$(ANSIBLETARGET):
	/bin/cp $(MAKESERVERDIR)/$(DIRECTORYNAME)/$@ ./$@

$(BUILDPLAYBOOK):
	/bin/cp $(MAKESERVERDIR)/$(DIRECTORYNAME)/$@ ./$@

$(ROLEDIR):
	$(MAKEDIR) ./$@
	/bin/cp $(MAKESERVERDIR)/$(DIRECTORYNAME)/$@/Makefile ./$@/
	cd $@ && $(MAKE) all

$(SPECDIR):
	$(MAKEDIR) ./$@
	/bin/cp $(MAKESERVERDIR)/$(DIRECTORYNAME)/$@/Makefile ./$@/
	cd $@ && $(MAKE) all


group_vars:
	$(MAKEDIR) ./$@
	/bin/cp $(MAKESERVERDIR)/$(DIRECTORYNAME)/$@/* ./$@/

role-index:
	@cd $(ROLEDIR) && $(MAKE) $@

clean:
	/bin/cp /dev/null $(ANSIBLECMDLOG)

