#!/bin/sh
#
PATH="/usr/local/bin:/usr/bin:/bin"
LANG="C"
LC_CTYPE="C"

if [ "$LOGNAME" = "vagrant" ]; then
    perl -i -ple 's/(nameserver) .+\z/$1 8.8.8.8/' /etc/resolv.conf
fi

