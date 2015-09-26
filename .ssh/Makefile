# Makefile for make-server/.ssh
#            _        ____  __       _         __ _ _      
#    ___ ___| |__    / /  \/  | __ _| | _____ / _(_) | ___ 
#   / __/ __| '_ \  / /| |\/| |/ _` | |/ / _ \ |_| | |/ _ \
#  _\__ \__ \ | | |/ / | |  | | (_| |   <  __/  _| | |  __/
# (_)___/___/_| |_/_/  |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
HEREIAM := $(shell pwd)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)
CURNODE := $(shell echo $(dir $(HEREIAM)) | xargs basename )

.DEFAULT_GOAL := all
MAKESERVERCTL := makeserverctl
SSH2SECRETKEY  = $(notdir $(DEPLOYKEY))
SSH2PUBLICKEY  = $(subst key,pub,$(SSH2SECRETKEY))

# ---------------------------------------------------------------------------
.PHONY: clean all
.SUFFIXES: .key .pub
.directory-location:
	@$(MAKESERVERCTL) --location

all: .directory-location $(SSH2PUBLICKEY)

$(SSH2SECRETKEY):
	ssh-keygen -vf $(SSH2SECRETKEY) -N '' -C "$(DEPLOYUSER)@$(CURNODE)"

.key.pub:
	test -f $(SSH2SECRETKEY).pub && mv $(SSH2SECRETKEY).pub $(SSH2PUBLICKEY)

clean:

