# Makefile for make-server/bin
#  _     _          ____  __       _         __ _ _      
# | |__ (_)_ __    / /  \/  | __ _| | _____ / _(_) | ___ 
# | '_ \| | '_ \  / /| |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | |_) | | | | |/ / | |  | | (_| |   <  __/  _| | |  __/
# |_.__/|_|_| |_/_/  |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
HEREIAM := $(shell pwd)
PWDNAME := $(shell echo $(HEREIAM) | xargs basename)
SCRIPTS := makeserverctl
PREFIX   = /usr/local

.DEFAULT_GOAL := command
MAKESERVERDIR  = $(shell head -1 ../.make-server-directory)
MAKESERVERSYS := server

# ---------------------------------------------------------------------------
.PHONY: clean all
.SUFFIXES: .PL

$(SCRIPTS): $(SCRIPTS).PL
	cat $< | sed \
		-e 's|@@MAKESERVER_DISTRIBUTION_DIRECTORY@@|$(MAKESERVERDIR)|g' \
		-e 's|@@MAKESERVER_MAINPROGRAMS_DIRECTORY@@|$(MAKESERVERSYS)|g' > $@

command: $(SCRIPTS)
install: $(SCRIPTS)
	test -d $(PREFIX)/bin || mkdir -p $(PREFIX)/bin
	install -o root -m 0755 $(SCRIPTS) $(PREFIX)/bin

uninstall:
	for v in $(SCRIPTS); do rm -f $(PREFIX)/bin/$$v; done

clean:
	rm -f $(SCRIPTS)

