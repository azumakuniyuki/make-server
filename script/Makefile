# Makefile for make-server/script
#                _       _      ____  __       _         __ _ _      
#  ___  ___ _ __(_)_ __ | |_   / /  \/  | __ _| | _____ / _(_) | ___ 
# / __|/ __| '__| | '_ \| __| / /| |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# \__ \ (__| |  | | |_) | |_ / / | |  | | (_| |   <  __/  _| | |  __/
# |___/\___|_|  |_| .__/ \__/_/  |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
#                 |_|                                                
# ---------------------------------------------------------------------------
HEREIAM := $(shell pwd)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)
CURNODE := $(shell echo $(dir $(HEREIAM)) | xargs basename )

.DEFAULT_GOAL := files
MAKESERVERDIR  = $(shell head -1 ../.make-server-directory)
DIRECTORYNAME  = $(notdir $(HEREIAM))
HELPERSCRIPTS := 11-selinux-off.sh 12-sudo-config.sh 15-rewrite-dns.sh \
				 41-vagrant-uid.sh 80-setup-repos.sh 95-install-pkg.sh

# ---------------------------------------------------------------------------
.PHONY: clean all
.SUFFIXES: .sh
files: $(HELPERSCRIPTS)

$(HELPERSCRIPTS):
	/bin/cp $(MAKESERVERDIR)/$(DIRECTORYNAME)/$@ ./

update:
	for v in $(HELPERSCRIPTS); do mv $$v $$v.tmp; done
	$(MAKE) files clean

clean:
	rm -f ./*.tmp


