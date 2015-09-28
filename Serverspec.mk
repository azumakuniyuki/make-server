# Makefile for make-server/Serverspec
#  ____                                                           _    
# / ___|  ___ _ ____   _____ _ __ ___ _ __   ___  ___   _ __ ___ | | __
# \___ \ / _ \ '__\ \ / / _ \ '__/ __| '_ \ / _ \/ __| | '_ ` _ \| |/ /
#  ___) |  __/ |   \ V /  __/ |  \__ \ |_) |  __/ (__ _| | | | | |   < 
# |____/ \___|_|    \_/ \___|_|  |___/ .__/ \___|\___(_)_| |_| |_|_|\_\
#                                    |_|                               
# ---------------------------------------------------------------------------
HEREIAM := $(shell pwd)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)

.DEFAULT_GOAL := test
ROOTDIRECTORY := server
MAKESERVERCTL := makeserverctl
TOBEINSTALLED := serverspec highline rake
INVENTORYFILE  = $(shell head -1 .default-inventoryfile)

# ---------------------------------------------------------------------------
.PHONY: clean all $(SUBDIRS)
.directory-location:
	@$(MAKESERVERCTL) --location

install:
	gem install $(TOBEINSTALLED)

test:
	@$(MAKE) .directory-location
	rake INVENTORY=$(INVENTORYFILE) spec

clean:

