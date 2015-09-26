# Makefile for make-server/lib
#  _ _ _       ____  __       _         __ _ _      
# | (_) |__   / /  \/  | __ _| | _____ / _(_) | ___ 
# | | | '_ \ / /| |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | | | |_) / / | |  | | (_| |   <  __/  _| | |  __/
# |_|_|_.__/_/  |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
HEREIAM := $(shell pwd)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)
CURNODE := $(shell echo $(dir $(HEREIAM)) | xargs basename )

.DEFAULT_GOAL := files
MAKESERVERCTL := makeserverctl
MAKESERVERDIR  = $(shell head -1 ../.make-server-directory)
HELPERSCRIPTS := ansible_helper.rb spec_helper.rb
DIRECTORYNAME  = $(notdir $(HEREIAM))

# ---------------------------------------------------------------------------
.PHONY: clean all
.SUFFIXES: .rb
.directory-location:
	@$(MAKESERVERCTL) --location

files: .directory-location $(HELPERSCRIPTS)

$(HELPERSCRIPTS):
	/bin/cp $(MAKESERVERDIR)/$(DIRECTORYNAME)/$@ ./

clean:

