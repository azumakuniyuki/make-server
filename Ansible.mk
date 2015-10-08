# Makefile for make-server/Ansible
#     _              _ _     _                  _    
#    / \   _ __  ___(_) |__ | | ___   _ __ ___ | | __
#   / _ \ | '_ \/ __| | '_ \| |/ _ \ | '_ ` _ \| |/ /
#  / ___ \| | | \__ \ | |_) | |  __/_| | | | | |   < 
# /_/   \_\_| |_|___/_|_.__/|_|\___(_)_| |_| |_|_|\_\
# -----------------------------------------------------------------------------
HEREIAM := $(shell pwd)
ANSIBLE := $(shell which ansible)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)
CURNODE := $(shell echo $(dir $(HEREIAM)) | xargs basename )
MAKEDIR := mkdir -p

.DEFAULT_GOAL := login
ROOTDIRECTORY := server
MAKESERVERDIR  = $(shell head -1 .make-server-directory)
DEPENDENCIES0 := pip
DEPENDENCIES1 := paramiko PyYAML Jinja2 httplib2 six
TOBEINSTALLED := ansible
EXECUTE_AFTER  = 10
BUILDPLAYBOOK  = $(ROOTDIRECTORY)/$(shell head -1 .default-playbook-file)
INVENTORYFILE  = $(ROOTDIRECTORY)/$(shell head -1 .default-inventoryfile)
INITPLAYBOOKS := $(ROOTDIRECTORY)/10-build-stage.yml \
				 $(ROOTDIRECTORY)/11-selinux-off.yml \
				 $(ROOTDIRECTORY)/20-deploy-user.yml

# -----------------------------------------------------------------------------
.PHONY: clean
build:
	@echo '*** The following playbook will be executed by ansible-playbook command:'
	@echo '  - Playbook to be executed    :' $(BUILDPLAYBOOK)
	@echo '  - Inventory file to be loaded:' $(INVENTORYFILE)
	@echo -n '*** Are you sure you want to execute the playbook above? [Y/n] '
	@read want_to_execute_playbook; \
	 case $${want_to_execute_playbook} in \
		[Yy]|[Yy]es|YES) \
			printf "%s" '*** make-server execute playbook after '; \
			n=$(EXECUTE_AFTER); while [ $$n -gt 0 ]; do printf "%2d seconds ..." $$n; \
				sleep 1; t=14; while [ $$t -gt 0 ]; do printf "\x08"; t=`expr $$t - 1`; done; \
				n=`expr $$n - 1`; \
			done; \
			echo; \
			ansible-playbook -i $(INVENTORYFILE) $(BUILDPLAYBOOK) ;; \
		[Nn]|[Nn]o|NO)   exit 0 ;; \
		*)               false  ;; \
	 esac

init-host:
	@echo    '*** The following playbooks are executed by ansible-playbook command:'
	@echo    '  - Playbooks to be executed:'
	@echo    '    - $(ROOTDIRECTORY)/10-build-stage.yml'
	@echo    '    - $(ROOTDIRECTORY)/11-selinux-off.yml'
	@echo    '    - $(ROOTDIRECTORY)/20-deploy-user.yml'
	@echo    '  - Inventory file to be loaded:'
	@echo    '    - $(INVENTORYFILE)'
	@echo -n '*** Are you sure you want to execute the playbooks above? [Y/n] '
	@read want_to_execute_playbooks; \
	 case $${want_to_execute_playbooks} in \
		[Yy]|[Yy]es|YES) \
			printf "%s" '*** make-server execute playbooks after '; \
			n=$(EXECUTE_AFTER); while [ $$n -gt 0 ]; do printf "%2d seconds ..." $$n; \
				sleep 1; t=14; while [ $$t -gt 0 ]; do printf "\x08"; t=`expr $$t - 1`; done; \
				n=`expr $$n - 1`; \
			done; \
			echo; \
			ansible-playbook -i $(INVENTORYFILE) $(INITPLAYBOOKS) ;; \
		[Nn]|[Nn]o|NO)   exit 0 ;; \
		*)               false  ;; \
	 esac

install:
	$(MAKE) install-depends
	pip install  $(TOBEINSTALLED)

install-depends:
	easy_install $(DEPENDENCIES0)
	hash -r
	pip install  $(DEPENDENCIES1)

node:
	$(ANSIBLE) all -i $(INVENTORYFILE) -m raw -a 'hostname'

ping:
	$(ANSIBLE) all -i $(INVENTORYFILE) -m ping

vars:
	$(ANSIBLE) all -i $(INVENTORYFILE) -m setup > $@

clean:
	for v in `/bin/ls -1 ~/*.retry 2> /dev/null`; do rm -f $$v; done

