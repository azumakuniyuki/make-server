# Makefile for make-server/server/roles
#                                __         _              ____  __       _         __ _ _      
#  ___  ___ _ ____   _____ _ __ / / __ ___ | | ___  ___   / /  \/  | __ _| | _____ / _(_) | ___ 
# / __|/ _ \ '__\ \ / / _ \ '__/ / '__/ _ \| |/ _ \/ __| / /| |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# \__ \  __/ |   \ V /  __/ | / /| | | (_) | |  __/\__ \/ / | |  | | (_| |   <  __/  _| | |  __/
# |___/\___|_|    \_/ \___|_|/_/ |_|  \___/|_|\___||___/_/  |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
HEREIAM := $(shell pwd)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)
MAKEDIR := mkdir -p

.DEFAULT_GOAL := all
MAKESERVERCTL := makeserverctl
MAKESERVERDIR  = $(shell head -1 ../../.make-server-directory)
DIRECTORYNAME  = server/roles
SUBDIRSINROLE := files handlers tasks templates vars defaults meta spec
INCLUDINGMAIN := handlers tasks vars meta
AVAILABLEROLE  = $(shell $(roleindex))
CPCOMMANDOPTS  = -i

define roleindex
find $(MAKESERVERDIR)/$(DIRECTORYNAME) -type f -name 'main.yml' -path '*/tasks/*' \
	| sed -e 's|/tasks/main.yml||g' -e 's|^.*/$(DIRECTORYNAME)/||g' 
endef

# -----------------------------------------------------------------------------
.PHONY: clean all
.SUFFIXES:
.directory-location:
	@$(MAKESERVERCTL) --location

all: .directory-location

$(AVAILABLEROLE):
	$(MAKE) .directory-location
	$(MAKEDIR) `dirname $@`
	/bin/cp -vRp $(CPCOMMANDOPTS) $(MAKESERVERDIR)/$(DIRECTORYNAME)/$@ ./`dirname $@`/

%-role:
	$(MAKE) $@-to-be-created

%-role-to-be-created:
	if [ -d "$(MAKESERVERDIR)/$(DIRECTORYNAME)/$*" ]; then \
		$(MAKE) $*; \
	else \
		$(MAKE) $*-new-role-directory; \
	fi

%-new-role-directory:
	for v in $(SUBDIRSINROLE); do $(MAKEDIR) ./$*/$$v; done
	for v in $(INCLUDINGMAIN); do touch ./$*/$$v/main.yml; done
	if [ -n "`figlet neko 2> /dev/null`" ]; then \
		for v in $(INCLUDINGMAIN); do \
			p="./$*/$$v/main.yml"; \
			if [ ! -e "$$p" -o ! -s "$$p" ]; then \
				touch $$p; \
				figlet -w128 "`echo $* | cut -d '/' -f2`/$$v" | sed 's/^/# /g' >> $$p; \
			fi \
		done \
	fi

role-index:
	@echo '*****************************************************************************'
	@echo ' `make <role-name>-role` command copy or create specified role directories in'
	@echo ' ./$(DIRECTORYNAME). Available roles are below:'
	@echo '*****************************************************************************'
	@$(MAKESERVERCTL) --role-index

clean:

