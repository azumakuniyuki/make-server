# Makefile for make-server/server/spec
#                                __                      ____  __       _         __ _ _      
#  ___  ___ _ ____   _____ _ __ / /__ _ __   ___  ___   / /  \/  | __ _| | _____ / _(_) | ___ 
# / __|/ _ \ '__\ \ / / _ \ '__/ / __| '_ \ / _ \/ __| / /| |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# \__ \  __/ |   \ V /  __/ | / /\__ \ |_) |  __/ (__ / / | |  | | (_| |   <  __/  _| | |  __/
# |___/\___|_|    \_/ \___|_|/_/ |___/ .__/ \___|\___/_/  |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
#                                    |_|                                                      
# -----------------------------------------------------------------------------
HEREIAM := $(shell pwd)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)
MAKEDIR := mkdir -p

.DEFAULT_GOAL := all
MAKESERVERDIR  = $(shell head -1 ../../.make-server-directory)
DIRECTORYNAME  = server/spec
RSPECFILELIST := 10-build-stage.rb 11-selinux-off.rb 20-deploy-user.rb \
				 30-update-sshd.rb

# -----------------------------------------------------------------------------
.PHONY: clean all
.SUFFIXES: .rb
all: $(RSPECFILELIST)

$(RSPECFILELIST):
	/bin/cp $(MAKESERVERDIR)/$(DIRECTORYNAME)/$@ ./

clean:

