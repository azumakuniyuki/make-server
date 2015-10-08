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
MAKESERVERDIR  = $(shell head -1 ../.make-server-directory)
DIRECTORYNAME  = $(notdir $(HEREIAM))
HELPERSCRIPTS := ansible_helper.rb spec_helper.rb

# ---------------------------------------------------------------------------
.PHONY: clean all
.SUFFIXES: .rb
files: $(HELPERSCRIPTS)

$(HELPERSCRIPTS):
	/bin/cp $(MAKESERVERDIR)/$(DIRECTORYNAME)/$@ ./

clean:

